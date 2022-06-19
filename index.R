#' ---
#' title: "Trabajo final de Estadística Computacional"
#' author: "Pedro Alumbreros Menchén, Elena Merelo Molina, Iván Salido Cobo y Rubén Vílchez Valenzuela"
#' date: "`r Sys.Date()`"
#' output:
#'   rmdformats::downcute:
#'   code_folding: show
#' self_contained: true
#' thumbnails: false
#' lightbox: true
#' downcute_theme: "chaos"
#' pkgdown:
#'   as_is: true
#' vignette: >
#'   %\VignetteIndexEntry{Trabajo final de Estadística Computacional}
#'   %\VignetteEngine{knitr::rmarkdown}
#'   %\VignetteEncoding{UTF-8}
#' ---
#' # Análisis del texto de distintas obras de prosa, poesía y teatro del Siglo de Oro español
#' El objetivo es analizar las principales diferencias entre las obras más famosas de prosa, poesía y teatro escritas en España durante el siglo XVII.
#' 
#' Las obras escogidas son:
#' 
#' - **Prosa:**
#'   - El ingenioso hidalgo Don Quijote de la Mancha
#'   - El ingenioso caballero Don Quijote de la Mancha
#' - **Poesía:**
#'   - La Divina comedia.
#' - **Teatro:**
#'   - La vida es sueño.
#' 
#' ## Paquetes utilizados
#' 
#' Como las obras están en PDF, se hará uso del paquete `pdftools` para extraer el texto.
#' 
#' Después, se usarán los paquetes `tokenizers` y `stopwords` para descomponer el texto y filtrar ciertas palabras.
#' 
#' Por último, se analizarán los datos resultantes con el paquete `tidyverse`.

library(tokenizers)
options(max.print = 4)
library(pdftools)
library(stopwords)

#' ## Leyendo los PDFs
#' 
#' En una lista se almacenan los PDFs que haya en el directorio de trabajo. El paguete `pdftools` permite leer el texto de un PDF con la función `pdf_text`. Se continúa leyendo el texto de todos los PDFs utilizando `lapply`.

pdfs <- list.files(pattern = "pdf$")
libros <- lapply(pdfs, pdf_text)
names(libros) <- c("DivinaComedia", "Quijote1", "Quijote2", "VidaEsSueño") 

#' Donde `libros` es una lista con los PDFs. Cada elemento de la lista (cada libro)
#' es un vector con tantos elementos como páginas tenga el PDF y en cada elemento
#' el texto que haya en esa página del PDF.
#' 
#' ## Preparando los datos
#' 
#' Ahora es necesario *tokenizar* el texto leído.
#' 
#' El proceso de *tokenización* consiste en descomponer una cadena de texto en *tokens*, esto es, elementos más pequeños computables. Un ejemplo sería la descomposición del texto en palabras o en letras.
#' Por otro lado, se usarán herramientas para procesar textos en distintos formatos con el fin de facilitar su manipulación.
#' 
#' Con la función `tokenize_words` se extraen y se almacenan las palabras.

palabxpag_lib <- lapply(libros, tokenize_words) 
palab_lib <- lapply(palabxpag_lib, unlist)
palab_lib

#' Donde `palab_libro` es una lista de vectores con todas las palabras de cada libro.
#' A la hora de extraer las palabras, podemos además especificar un vector de palabras vacías *(palabras que no tienen un significado por sí solas, como pueden ser artículos, pronombres, preposiciones, adverbios, ...)*, que se omitirán.
#' Para esto es útil el paquete `stopwords`, que contiene las palabras vacías o *stopwords* para distintos idiomas. El idioma se especifica como argumento en forma de su código ISO 639-1, por ejemplo, para el español, se usa el código `"es"`. Un ejemplo donde extraemos las palabras de un libro especificando palabras vacías del español con ayuda del paquete stopwords:

pvacias <- tokenize_words(libros[[1]], stopwords = stopwords::stopwords("es"))
pvacias[[1]]

#' Otra opción a la hora de analizar las palabras de un texto es tomar las raíces de las palabras en lugar de las palabras completas, lo cual da pie a más formas de estudiar un texto desde el punto de vista lingüístico. Esto se puede conseguir con ayuda de la función `tokenize_word_stems`:

raizpalabxpag_lib <- lapply(libros, tokenize_word_stems) 
raizpalab_lib <- lapply(raizpalabxpag_lib, unlist)
raizpalab_lib

#' No solo nos quedamos en las palabras, si no que además podemos tomar el texto y separarlo en todas las letras que lo componen, que son los menores *tokens* que podremos encontrar.

letrasxpag_lib <- lapply(libros, tokenize_characters)
letras_lib <- lapply(letrasxpag_lib, unlist)
letras_lib

#' En el paquete encontramos otra función que permite dividir el texto en partes más pequeñas de igual longitud.

texto <- chunk_text(libros$Quijote1[7], chunk_size = 80)
texto[2:5]

#' También se pueden separar párrafos y frases con las funciones `tokenize_sentences` y `tokenize_paragraphs` respectivamente. Vemos un ejemplo de separación de frases. 

tokenize_sentences(libros$Quijote1[[20]])

#' Además se pueden contar letras, palabras o frases de un texto con las funciones `count_words`, `count_characters` y `count_sentences` respectivamente.
#' Aunque es posible *tokenizar* el texto con las funciones ya vistas y computar la longitud de los vectores obtenidos, estas funciones nos ofrecen un recuento de forma directa si no queremos dar pasos intermedios.
#' Contamos las palabras de una página del `Quijote2`:

count_words(libros$Quijote2[[9]])

#' Otra opción a la hora de *tokenizar* el texto, igual que tomar frases, palabras, o párrafos, es tomar *n-gramas*: subsecuencias de a lo sumo *n* elementos contiguos de una secuencia dada, y como mínimo *n_min* elementos. En este caso es también posible utilizar la opción de excluir palabras vacías si se desea. Veamos un ejemplo donde tomamos *n-gramas* de entre *1* y *6* palabras:

ngrama <- tokenize_ngrams(libros[[1]], n = 6, n_min = 1)
ngrama[[1]]

#' Veamos el mismo caso omitiendo palabras vacías:

ngrama_stopwords <- tokenize_ngrams(libros[[1]], n = 6, n_min = 1, stopwords = stopwords::stopwords("es"))
ngrama_stopwords[[1]]

#' A raíz de esto surge también la opción de tomar *n-gramas* con *k-saltos*: como su propio nombre indica, hace lo mismo que el proceso de tomar *n-gramas*, pero con la opción de omitir entre *0* y *k* palabras en el *n-grama*, en lugar de tomar subsecuencias con todas las palabras contiguas. De nuevo, es posible incluir una lista de palabras vacías que evitar en el proceso.

ngrama_salto <- tokenize_skip_ngrams(libros[[1]], n = 3, n_min = 1, k = 1)
ngrama_salto[[1]]
ngrama_salto_stopwords <- tokenize_skip_ngrams(libros[[1]], n = 3, n_min = 1, k = 1, stopwords = stopwords::stopwords("es"))
ngrama_salto_stopwords[[1]]

#' 
#' ## Analizando los datos
#' 
#' asfdasf