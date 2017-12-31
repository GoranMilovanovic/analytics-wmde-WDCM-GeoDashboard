### ---------------------------------------------------------------------------
### --- WDCM Geo Dashboard, v. Beta 0.1
### --- Script: server.R, v. Beta 0.1
### ---------------------------------------------------------------------------

### --- Setup

### --------------------------------
### --- general
library(shiny)
library(shinydashboard)
library(data.table)
library(DT)
library(stringr)
### --- visualize
library(leaflet)

### --- Server (Session) Scope
### --------------------------------

### --- Fetch local files
setwd('/srv/shiny-server/WDCM_GeoDashboard/data/')

### --- fetch projecttopic tables
lF <- list.files()
lF <- lF[grepl("^wdcm_geoitem_", lF)]
categories <- vector(mode = "list", length = length(lF))
for (i in 1:length(lF)) {
  categories[[i]] <- fread(lF[i], data.table = F)
}
names(categories) <- str_to_title(sapply(lF, function(x) {
  strsplit(strsplit(x, split = ".", fixed = T)[[1]][1],
           split = "_",
           fixed = T)[[1]][3]
}))


### --- Fetch update info
setwd('/srv/shiny-server/WDCM_GeoDashboard/update/')
update <- read.csv('toLabsGeoReport.csv', 
                   header = T,
                   check.names = F,
                   stringsAsFactors = F,
                   row.names = 1)

### --- shinyServer
shinyServer(function(input, output, session) {
  
  ### --- output: updateInfo
  output$updateInfo <- renderText({
    date <- update$timeStamp[dim(update)[1]]
    date <- strsplit(as.character(date), split = " ", fixed = T)[[1]][1]
    date <- strsplit(date, split = "-", fixed = T)
    date[[1]][2] <- month.name[as.numeric(date[[1]][2])]
    date <- paste(unlist(date), collapse = " ")
    return(paste("<p align=right>Last update: <i>", date, "</i></p>", sep = ""))
  })
  
  ### ------------------------------------------
  ### --- TAB: tabPanel Maps
  ### ------------------------------------------
  
  ### --- SELECT: update select 'selectCategory'
  updateSelectizeInput(session,
                       'selectCategory',
                       "Select Semantic Category:",
                       choices = names(categories),
                       selected = names(categories)[round(runif(1, 1, length(categories)))],
                       server = TRUE)
  
  ### --- LEAFLET MAP:
  points <- eventReactive(input$selectCategory, {
    if (is.null(input$selectCategory) | (input$selectCategory == "")) {
      return(NULL)
    } else {
      outCat <- categories[[which(names(categories) %in% input$selectCategory)]]
      outCat[, 2:dim(outCat)[2]] 
    }
  }, ignoreNULL = FALSE)
  
  output$wdcmMap <- renderLeaflet({
    if (is.null(points())) {
      return(NULL) 
    } else {
      leaflet() %>%
        addTiles() %>%
        addMarkers(data = points(), 
                   popup = (paste('<b>', points()$label, '</b><br>',
                                  '<a href="https://www.wikidata.org/wiki/', points()$item, '" target = "_blank">', points()$item, '</a><br>',
                                  'Usage: ', points()$usage, sep = "")
                            ),
                   clusterOptions = markerClusterOptions()
                   )
    }
    }) %>% withProgress(message = 'Generating map',
                      min = 0,
                      max = 1,
                      value = 1, {incProgress(amount = 1)})

  ### ------------------------------------------
  ### --- TAB: tabPanel Data
  ### ------------------------------------------
  
  ### --- output$mapData
  output$mapData <- DT::renderDataTable({
    datatable(points(),
              options = list(
                pageLength = 20,
                width = '100%',
                columnDefs = list(list(className = 'dt-center', targets = "_all"))
              ),
              rownames = FALSE
    )
  }) %>% withProgress(message = 'Generating data',
                      min = 0,
                      max = 1,
                      value = 1, {incProgress(amount = 1)})
  
  ### --- download map data
  # - Download: tabulations_projectsChart
  output$mapDataCSV <- downloadHandler(
    filename = function() {
      'WDCM_Data.csv'},
    content = function(file) {
      write.csv(points(),
                file,
                quote = FALSE,
                row.names = FALSE)
    },
    contentType = "text/csv"
  )
  
}) ### --- END shinyServer










