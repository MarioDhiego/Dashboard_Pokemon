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
  
output$visualizar <- downloadHandler(
  filename = function(){
  glue::glue("relatorio_{input$pokemon}.pdf")  
  },
  content =  function(file){
   
    rmarkdown::render(
      input = "relatorio.Rmd",
      output_file = "arquivo.html",
      params = list(pokemon = input$pokemon)
    )
    
    pagedown::chrome_print(
      input = "arquivo.html",
      output = file
    )
    
     
  }
  
  
  
)  
}


shinyApp(ui, server)















