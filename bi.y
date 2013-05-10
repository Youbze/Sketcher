%{
	#include <stdlib.h>
	#include <stdio.h>		
	#include <math.h>
	#include <cairo.h>
	#include <cairo-pdf.h>
	#include <string.h>
	#include <assert.h>

	#define DOUBLE 	1
	#define INT 	2
	#define POINT 	3
	#define PATH 	4

	/****************STRUCTURES****************/
	typedef struct {			// Structure représentant un point
		double x;
		double y;
		int isRelative;
	}s_point;

	struct s_table{				// Table contenant les variables créées par l'utilisateur
		char *name;
		int type;
		union {					// Une variable n'est que d'un seul type, autant économiser la mémoire
			double d_value;
			int i_value;
			s_point p_value;
			s_point* c_value;
		} value;
		int size;
		struct s_table *next;
	};
	
	int varMode = 0;

	typedef struct s_table table;
	/**************************************************/

	/****************VARIABLES GLOBALES****************/
	cairo_surface_t * pdf_surface;	// Le pdf dans lequel on va écrire
	cairo_t* cr;					// Le contexte cairo
	s_point *tab_points;			// Le tableau contenant l'esemble des points dans la commande en cours de traitement
	int i_pts;						// Le nombre de points actuellement présents dans tab_points
	int tab_size;					// La taille max de tab_points (pour l'allocation dynamique)
	table *var_table = NULL;		// La table de variables
	/**************************************************/


	/****************FONCTIONS****************/
	
	table *getvar(char* name){			// Récupération d'une variable par son nom dans la table
		
		table *iter = var_table;
		
		while(iter != NULL){
			if (strcmp(iter->name, name) == 0){
				return iter;
			}

			iter = (table*) iter->next;
		}

		return NULL;
	}

	table *addvar(char* name, int type){	// Ajout d'une variable dans la table

		table *var = getvar(name);

		if (var == NULL)
			var = malloc(sizeof(table));

		var->type = type;
		var->name = malloc((strlen(name) + 1)*sizeof(char));
		strcpy(var->name,name);
		var->size = 0;

		var->next = (table*) var_table;

		var_table = var;

		return var;
	}



	

	void extend_tab()					// Agrandissement du tableau de points dynamique
	{
		s_point *tmp = malloc(2*tab_size*sizeof(s_point));
		int i;
		for(i=0;i<tab_size;i++)
			tmp[i] = tab_points[i];
		free(tab_points);
		tab_points = tmp;
	}

	freee()								// Libération de la mémoire
	{
		table *iter = var_table;
		table *tmp;
		while(iter != NULL){
			if (iter->type == PATH)
				free(iter->value.c_value);
			tmp = iter;
			iter = (table*) iter->next;
			free(tmp);
		}
		//free(tab_points); (pas celui la il est global)
	}

	/**************************************************/
%}

%union {
	int entier;
	double decimal;
	s_point sp;
	char* str;
}

%type <sp> point cart pol
%type <decimal> exp

%token T_INT T_DOUBLE T_POINT T_PATH PI

%token DRAW FILL CYCLE
%token <decimal> NB
%token <str> STR
%token EOL ENDFILE

%token SEPARATOR RELATIVE_SEPARATOR
%token ROTATE TRANSLATE

%left '-' '+' '/' '*' SEPARATOR RELATIVE_SEPARATOR

%%																						// Symbole de départ
in:		line in ENDFILE {printf("End of stream reached, exiting...\n"); return 0;}		// Entrée complète exploitable
		| 																				// Ou rien
		| EOL																			// Ou \n
		;
																						// Dans une ligne :
line: 	cmd EOL																			// Une commande
		| error EOL	{printf("\nERROR\n");}												// Ou une erreur
		;
																						// Une commande peut être :
cmd:	DRAW points ';' {																// Une commande de dessin simple avec une liste de points
					int i;
					for(i=0;i<i_pts;i++)
					{
						if(tab_points[i].isRelative && i > 0)
						{
							tab_points[i].x+=tab_points[i-1].x;
							tab_points[i].y+=tab_points[i-1].y;
						}
						cairo_line_to(cr, tab_points[i].x, tab_points[i].y);
					}

					cairo_stroke(cr);
					i_pts = 0;
				}
		| FILL points ';' {																// Une commande de dessin simple avec une liste de points
					int i;
					for(i=0;i<i_pts;i++)
					{
						if(tab_points[i].isRelative && i > 0)
						{
							tab_points[i].x+=tab_points[i-1].x;
							tab_points[i].y+=tab_points[i-1].y;
						}
						cairo_line_to(cr, tab_points[i].x, tab_points[i].y);
					}

					cairo_fill(cr);
					i_pts = 0;
				}
		| var ';'																		// Ou une déclaration de variable
		| function ';'																	// Ou un appel de fonction
		;
																						// Une fonction est :
function: ROTATE '(' STR ',' point ',' exp ')' {										// Une rotation
												table* var = getvar($3);
												s_point centre = $5;
												if (var->type == POINT){
													double x2 = var->value.p_value.x;
													double y2 = var->value.p_value.y;
													double d = sqrt((centre.x - x2) * (centre.x - x2) + (centre.y - y2) * (centre.y - y2));
													var->value.p_value.x = centre.x + (x2-centre.x) * cos($7) - (y2-centre.y) * sin($7); 
													var->value.p_value.y = centre.y + (x2-centre.x) * sin($7) + (y2-centre.y) * cos($7); 
												}else if (var->type == PATH){												
													int i;
													/*
													 * Rotation d'un chemin
													 * Puis dessine le nouveau chemin
													 */ 
													for(i=0;i<var->size;i++){
														double x2 = tab_points[i].x;
														double y2 = tab_points[i].y;
														double d = sqrt((centre.x - x2) * (centre.x - x2) + (centre.y - y2) * (centre.y - y2));
														tab_points[i].x = centre.x + (x2-centre.x) * cos($7) - (y2-centre.y) * sin($7); 
														tab_points[i].y = centre.y + (x2-centre.x) * sin($7) + (y2-centre.y) * cos($7);   
														cairo_line_to(cr, tab_points[i].x, tab_points[i].y);
													}
													
													cairo_stroke(cr);
												}
												}
			|									
			TRANSLATE '(' STR ',' point ')' {											// Ou une translation
												table* var = getvar($3);
												if (var->type == POINT){
													double x2 = var->value.p_value.x;
													double y2 = var->value.p_value.y;
													var->value.p_value.x += $5.x;
													var->value.p_value.y += $5.y;
												}else if (var->type == PATH){												
													int i;
													/*
													 * Translation d'un chemin
													 * Puis dessine le nouveau chemin
													 */ 
													for(i=0;i<var->size;i++){
														tab_points[i].x += $5.x;
														tab_points[i].y += $5.y;   
														cairo_line_to(cr, tab_points[i].x, tab_points[i].y);
													}
													
													cairo_stroke(cr);
												}
												}							
		;

									
																						// Une liste de points contient :
points:	point 					{														// Un point
									if (varMode==0){
										if(i_pts == tab_size)
											extend_tab();
										tab_points[i_pts] = $1;
										tab_points[i_pts].isRelative = 0;
										i_pts++;
									}
								}

																						//Coordonnees absolues
		| points SEPARATOR point 	{													// Ou un ensemble de points en coordonnées absolues
									if(i_pts == tab_size)
										extend_tab();
									tab_points[i_pts] = $3;
									tab_points[i_pts].isRelative = 0;
									i_pts++;
								}
																						//Coordonnees relatives
		| points RELATIVE_SEPARATOR point {												// Ou un ensemble de points en coordonnées relatives
									if(i_pts == tab_size)
										extend_tab();
									tab_points[i_pts] = $3;
									tab_points[i_pts].isRelative = 1;
									i_pts++;
								}					
		;
																						// Un point est :
point:	cart 					{														// Une paire de coordonnées cartésiennes
									$$ = $1;
								}
		| pol					{														// Ou une paire de coordonnées polaires
									$$ = $1;
								}
		| CYCLE					{														// Ou le 1er point du chemin (pour former des cycles)
									$$ = tab_points[0];
								}
		| STR					{														// Ou une variable
									table* var = getvar($1);
									if (var->type == POINT)
										$$ = var->value.p_value;
									else if (var->type == PATH)
										varMode = 1;
								}
		;

cart:	'('exp','exp')'			{														//Des coordonnées cartésiennes sont une paire d'expressions entre parenthèses séparées par une virgule
									s_point res;
									res.x = $2;
									res.y = $4;
									$$ = res;
								}
		;

pol:	'('exp':'exp')'			{														//Des coordonnées polaires sont une paire d'expressions entre parenthèses séparées par le caractère ':'
									s_point res;
									res.x = $4*cos($2);
									res.y = $4*sin($2);
									$$ = res;
								}
		;
																						// Une déclaration de variable peut concerner :
var: T_INT STR '=' exp			{														// Un entier
									table* var = addvar($2, INT);
									var->value.i_value = $4;
									var->size = 1;
								}
	| T_DOUBLE STR '=' exp		{														// Ou un décimal
									table* var = addvar($2, DOUBLE);
									var->value.d_value = $4;
									var->size = 1;
								}
	| T_POINT STR '=' point 	{														// Ou un point
									table* var = addvar($2, POINT);
									var->value.p_value = $4;
									var->size = 1;
								}
	| T_PATH STR '=' points		{														// Ou un chemin
									table* var = addvar($2, PATH);
									s_point *tmp = malloc(i_pts*sizeof(s_point));
									int i;
									for(i=0;i<i_pts;i++)
										tmp[i] = tab_points[i];
									var->value.c_value = tmp;
									var->size = i_pts;	
								}
	;	
																						// Une expression est :
exp:	NB						{														// Un nombre
									$$ = $1;
								}
		| STR 					{														// Ou une variable
									table* var = getvar($1);
									if (var == NULL){
										printf("Var `%s` doesn't exists\n", $1); YYABORT; }
									else if (var->type == INT)
										$$ = var->value.i_value; 
									else if (var->type == DOUBLE)
										$$ = var->value.d_value;

								}
		| PI					{														// Ou PI
									$$ = M_PI;
								}
		| '-'exp				{														// Ou l'opposé d'une expression
									$$ = -$2;
								}
		| exp '/' exp			{														// Ou le quotient de deux expressions
									$$ = $1/$3;
								}
		| exp '+' exp			{														// Ou la somme de deux expressions
									$$ = $1+$3;
								}
		| exp '*' exp			{														// Ou le produit de deux expressions
									$$ = $1*$3;
								}
		| exp '-' exp			{														// Ou la différence de deux expressions
									$$ = $1-$3;
								}
		| '('exp')'				{ $$ = $2; }											// Ou une expression entre parenthèses
		;

%%
yyerror(char* msg){
	printf("%s\n", msg);
}

int main(int argc, char *argv[]){

	pdf_surface = cairo_pdf_surface_create("out.pdf", 250, 250);		// Création du pdf
	cr = cairo_create(pdf_surface);										// Création du contexte cairo lié au pdf
	cairo_set_line_width (cr, 1.0);										// Initialisation de la largeur de trait
	i_pts = 0;															// Le tableau de points n'en contient aucun
	tab_size = 10;														// Et peut en contenir jusqu'a 10
	tab_points = malloc(10*sizeof(s_point));							// Allocation de la mémoire nécessaire
	yyparse();															// Lancement de la boucle d'analyse
	freee();															// Quand tout est fini libération de la mémoire
	cairo_destroy(cr);													// Destruction du contexte cairo
	cairo_surface_destroy(pdf_surface);									// Et de la représentation en mémoire du pdf
	return 0;
}
