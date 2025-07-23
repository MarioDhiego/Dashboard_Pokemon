# Pacotes
library(shiny)
library(pokemon)
library(pagedown)
library(pagedreport)
library(knitr)
library(glue)
library(dplyr)
library(stringr)

dados <- pokemon::pokemon_ptbr

ui <- fluidPage(
  titlePanel("BOLETIM POKEMON"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "pokemon",
        label = "Selecione Um POKEMON",
        choices = unique(dados$pokemon)
      ),
      actionButton("visualizar", "Visualizar relatório"),
      downloadButton("baixar", "Baixar relatório")
    ),
    mainPanel(
      uiOutput("preview")
    )
  )
)

server <- function(input, output, session){
  
  iframe <- eventReactive(input$visualizar, {
    rmarkdown::render(
      input = "relatorio.Rmd",
      output_file = "www/relatorio.html",
      params = list(pokemon = input$pokemon),
      envir = new.env(parent = globalenv())
    )
    
    tags$iframe(
      src = "relatorio.html",
      width = "100%",
      height = 600
    )
  })
  
  output$preview <- renderUI({ 
    req(iframe())
    iframe()
  })
  
  output$baixar <- downloadHandler(
    filename = function(){
      glue("relatorio_{input$pokemon}.pdf")
    },
    content =  function(file){
      withProgress(message = "GERANDO O RELATÓRIO EM HTML...", {
        incProgress(0.2)
        
        temp_html <- tempfile(fileext = ".html")
        
        rmarkdown::render(
          input = "relatorio.Rmd",
          output_file = temp_html,
          params = list(pokemon = input$pokemon),
          envir = new.env(parent = globalenv())
        )
        
        incProgress(0.6, message = "CONVERTENDO PARA PDF...")
        
        pagedown::chrome_print(
          input = temp_html,
          output = file
        )
      })
    }
  )  
}

shinyApp(ui, server)
