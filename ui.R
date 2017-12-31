### ---------------------------------------------------------------------------
### --- WDCM Geo Dashboard, v. Beta 0.1
### --- Script: ui.R, v. Beta 0.1
### ---------------------------------------------------------------------------

### --- Setup
rm(list = ls())
### --- general
library(shiny)
library(shinydashboard)
library(shinycssloaders)
### --- outputs
library(leaflet)
library(DT)

# - options
options(warn = -1)

shinyUI(
  
  fluidPage(title = 'WDCM Projects', 
            theme = NULL,
            
            # - fluidRow Title
            fluidRow(
              column(width = 5,
                     fluidRow(
                       column(width = 3,
                              img(src = 'Wikidata-logo-en.png',
                                  align = "left")
                       ),
                       column(width = 1),
                       column(width = 8,
                              h1('WDCM Geo Dashboard'),
                              HTML('<font size="5"><b>Wikidata Concepts Monitor</b></font>')
                       )
                     )
              ),
              column(width = 7,
                     br(),
                     HTML('<p align="right"><b>Interactive visualizations of Wikidata use by other Wikimedia projects.</b></p>'),
                     HTML('<p align="right"><b><a href = "https://www.wikidata.org/wiki/Wikidata:Wikidata_Concepts_Monitor" target="_blank">Visit the WDCM wiki page</a></b></p>'),
                     HTML('<p align="right"><b>Did you spot a bug, a missing label, or wrong data? <a href = "https://www.wikidata.org/wiki/Wikidata:Wikidata_Concepts_Monitor/UserFeedback" target="_blank">Give us feedback here</a></b></p>'),
                     htmlOutput('updateInfo')
              )
            ), # - fluidRow Title END
            
            # - hr()
            fluidRow(
              column(width = 12,
                     hr()
              )
            ),
            
            # - fluidRow Boxes
            fluidRow(
              column(width = 12,
                     tabBox(id = 'MainBox', 
                            selected = 'Dashboard', 
                            title = '', 
                            width = 12,
                            height = NULL, 
                            side = 'left',
                            
                            # - tabPanel Dashboard
                            tabPanel("Dashboard",
                                     fluidRow(
                                       column(width = 12,
                                              hr(),
                                              tabBox(width = 12,
                                                     title = '',
                                                     id = "Maps",
                                                     selected = "Maps",
                                                     tabPanel(title = "Maps",
                                                              id = "maps",
                                                              fluidRow(
                                                                column(width = 6,
                                                                       br(),
                                                                       HTML('<font size=2>Select Wikidata item category, and the Dashboard will generate an interactive map 
                                                                            where (at most) 10,000 most frequently used items are localized alongside their Wikidata usage 
                                                                            statistics. Click the item marker for details. <b>Note.</b> The usage statistic is the number of 
                                                                            pages that make use of the respective item across all Wikimedia projects.</font>')
                                                                       )
                                                                       ),
                                                              # - fluidRow: Selections
                                                              fluidRow(
                                                                br(),
                                                                column(width = 3,
                                                                       selectizeInput("selectCategory",
                                                                                      "Select Item Category:",
                                                                                      multiple = F,
                                                                                      choices = NULL,
                                                                                      selected = NULL)
                                                                )
                                                              ),
                                                              fluidRow(
                                                                column(width = 12, 
                                                                       hr(),
                                                                       withSpinner(leafletOutput("wdcmMap", width = "100%", height = 800))
                                                                       )
                                                                )
                                                     ), # - tabPanel Maps END
                                                     
                                                     # - tabPanel Data BEGIN
                                                     tabPanel(title = "Data",
                                                              id = "data",
                                                              fluidRow(
                                                                column(width = 12,
                                                                       fluidRow(
                                                                         column(width = 6,
                                                                                br(), 
                                                                                HTML('<font size = 2>The complete data set used to generate the map.</font>'),
                                                                                br()
                                                                                     )
                                                                                )
                                                                         )
                                                                       ),
                                                              # - fluidRow: Data
                                                              fluidRow(
                                                                br(),
                                                                column(width = 6,
                                                                       downloadButton('mapDataCSV',
                                                                                      'Data (csv)'),
                                                                       br(), br(),
                                                                       withSpinner(DT::dataTableOutput('mapData', width = "100%"))
                                                                )
                                                              )
                                                              ) # - tabPanel Data END
                                                     ) # - tabBox: Dashboard END
                                              )
                                       )
                                     ), # - tabPanel Dashboard END
                            
                            # - tabPanel Description
                            tabPanel("Description",
                                     fluidRow(
                                       column(width = 8,
                                              HTML('<h2>WDCM Geo Dashboard</h2>
                                                   <h4>Description<h4>
                                                   <hr>
                                                   <h4>Introduction<h4>
                                                   <br>
                                                   <p><font size = 2>This Dashboard is a part of the <b>Wikidata Concepts Monitor (WDMC)</b>. The WDCM system provides analytics on Wikidata usage
                                                   across the Wikimedia sister projects. The WDCM Geo Dashboard collects several categories of Wikidata items that have geographical coordinates data and 
                                                   presents them on an interactive <a href = "http://leafletjs.com/" target = "_blank">Leaflet map</a> alongside their usage statistics. To understand the WDCM usage statistics, check out the Definitions 
                                                   section. The WDCM Geo Dashboard uses <a href = "https://www.openstreetmap.org/" target = "_blank">OpenStreetMap</a>.
                                                   </font></p>
                                                   <hr>
                                                   <h4>Definitions</h4>
                                                   <br>
                                                   <p><font size = 2><b>N.B.</b> The current <b>Wikidata item usage statistic</b> definition is <i>the count of the number of pages in a particular client project
                                                   where the respective Wikidata item is used</i>. Thus, the current definition ignores the usage aspects completely. This definition is motivated by the currently 
                                                   present constraints in Wikidata usage tracking across the client projects 
                                                   (see <a href = "https://www.mediawiki.org/wiki/Wikibase/Schema/wbc_entity_usage" target = "_blank">Wikibase/Schema/wbc entity usage</a>). 
                                                   With more mature Wikidata usage tracking systems, the definition will become a subject 
                                                   of change. The term <b>Wikidata usage volume</b> is reserved for total Wikidata usage (i.e. the sum of usage statistics) in a particular 
                                                   client project, group of client projects, or semantic categories. By a <b>Wikidata semantic category</b> we mean a selection of Wikidata items that is 
                                                   that is operationally defined by a respective SPARQL query returning a selection of items that intuitivelly match a human, natural semantic category. 
                                                   The structure of Wikidata does not necessarily match any intuitive human semantics. In WDCM, an effort is made to select the semantic categories so to match 
                                                   the intuitive, everyday semantics as much as possible, in order to assist anyone involved in analytical work with this system. However, the choice of semantic 
                                                   categories in WDCM is not necessarily exhaustive (i.e. they do not necessarily cover all Wikidata items), neither the categories are necessarily 
                                                   mutually exclusive. The Wikidata ontology is very complex and a product of work of many people, so there is an optimization price to be paid in every attempt to 
                                                   adapt or simplify its present structure to the needs of a statistical analytical system such as WDCM. The current set of WDCM semantic categories is thus not 
                                                   normative in any sense and a subject  of change in any moment, depending upon the analytical needs of the community.</font></p>
                                                   <p>The currently used <b>WDCM Taxonomy</b> of Wikidata items encompasses the following 14 semantic categories: <i>Geographical Object</i>, <i>Organization</i>, <i>Architectural Structure</i>, 
                                                   <i>Human</i>, <i>Wikimedia</i>, <i>Work of Art</i>, <i>Book</i>, <i>Gene</i>, <i>Scientific Article</i>, <i>Chemical Entities</i>, <i>Astronomical Object</i>, <i>Thoroughfare</i>, <i>Event</i>, 
                                                   and <i>Taxon</i>.</p>
                                                   ')
                                              )
                                              )
                                              ), # - tabPanel Usage END
                            
                            # - tabPanel Navigate
                            tabPanel("Navigate WDCM", 
                                     fluidRow(
                                       column(width = 8,
                                              HTML('<h2>WDCM Navigate</h2>
                                                   <h4>Your orientation in the WDCM Dashboards System<h4>
                                                   <hr>
                                                   <ul>
                                                   <li><b><a href = "http://wdcm.wmflabs.org/">WDCM Portal</a></b><br>
                                                   <font size = "2">The entry point to WDCM Dashboards.</font></li><br>
                                                   <li><b><a href = "http://wdcm.wmflabs.org/WDCM_OverviewDashboard/">WDCM Overview</a></b><br>
                                                   <font size = "2">The big picture. Fundamental insights in how Wikidata is used across the client projects.</font></li><br>
                                                   <li><b><a href = "http://wdcm.wmflabs.org/WDCM_SemanticsDashboard/">WDCM Semantics</a></b><br>
                                                   <font size = "2">Detailed insights into the WDCM Taxonomy (a selection of semantic categories from Wikidata), its distributional
                                                   semantics, and the way it is used across the client projects. If you are looking for Topic Models - that&#8217;s where
                                                   they live.</font></li><br>
                                                   <li><b><a href = "http://wdcm.wmflabs.org/WDCM_UsageDashboard/">WDCM Usage</a></b><br>
                                                   <font size = "2">Fine-grained information on Wikidata usage across client projects and project types. Cross-tabulations and similar.</font></li><br>
                                                   <li><b>WDCM Items</b><br>
                                                   <font size = "2">Fine-grained information on particular Wikidata item usage across the client projects.<b> (Under development)</b></font></li><br>
                                                   <li><b><a href = "http://wdcm.wmflabs.org/WDCM_GeoDashboard/">WDCM Geo</a> (current dashboard)</b><br>
                                                   <font size = "2">Wikidata items interactive maps.</font></li><br>
                                                   <li><b><a href = "https://wikitech.wikimedia.org/wiki/Wikidata_Concepts_Monitor">WDCM System Technical Documentation</a></b><br>
                                                   <font size = "2">The WDCM Wikitech Page.</font></li>
                                                   </ul>'
                                                             )
                                                 )
                                               )
                                               ) # - tabPanel Structure END
                            
                            ) # - tabBox END
                     
                     ) # - main column of fluidRow Boxes END
              
              ), # - # - fluidRow Boxes END
            
            # - fluidRow Footer
            fluidRow(
              column(width = 12,
                     hr(),
                     HTML('<b>Wikidata Concepts Monitor :: WMDE 2017</b><br>Diffusion: <a href="https://phabricator.wikimedia.org/diffusion/AWCM/" target = "_blank">WDCM</a><br>'),
                     HTML('Contact: Goran S. Milovanovic, Data Scientist, WMDE<br>e-mail: goran.milovanovic_ext@wikimedia.de
                          <br>IRC: goransm'),
                     br(),
                     br()
                     )
            ) # - fluidRow Footer END
            
            ) # - fluidPage END
  
) # - ShinyUI END