# Pacotes
library(shiny)
library(pokemon)
library(pagedown)
library(pagedreport)

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
        params = list(pokemon = input$pokemon)
      )
      
      tag$iframe(
        src = "relatorio.html",
        width = "100%",
        heigth = 600
      )
      
    })

    output$preview <- renderUI({ 
      req(iframe())
      iframe()
      
    })
    
output$baixar <- downloadHandler(
  filename = function(){
  glue::glue("relatorio_{input$pokemon}.pdf")  
  },
  content =  function(file){
    
    withProgress(message = "GERANDO O RELATÓRIO EM HTML...",  {
      
      incProgress(0.2)
      arquivo_html <- tempfile(fileext = ".html")
      
      
      rmarkdown::render(
        input = "relatorio.Rmd",
        output_file = "arquivo_html",
        params = list(pokemon = input$pokemon)
      )
      
      incProgress(0.4, message = "RELATÓRIO EM PDF...")
      pagedown::chrome_print(
        input = "arquivo.html",
        output = file
      )
      
    })
  }
  
  
  
)  
}


shinyApp(ui, server)















