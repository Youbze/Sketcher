#include <cairo.h>
#include <cairo-pdf.h>

int main(void){
  cairo_surface_t *surface;
  cairo_t *cr;
  
  //Creation de la surface pdf associee au fichier ex1.pdf
  cairo_surface_t* pdf_surface = 
    cairo_pdf_surface_create("ex1.pdf",50,50);

  //Creation du contexte cairo associe a la surface
  cr=cairo_create(pdf_surface);
  //Place le point courant en (10,10)
  cairo_move_to(cr,10,10);
  //Enregistrer la ligne du point (10,10) au point (50,50)
  cairo_line_to(cr,50,50);
  //Met la largeur de trait a 10
  cairo_set_line_width (cr, 10.0);
  //Tracer la ligne
  cairo_stroke(cr);
  //Liberation du contexte
  cairo_destroy(cr);
  //Liberation de la surface
  cairo_surface_destroy(pdf_surface);
  return 0;
}
