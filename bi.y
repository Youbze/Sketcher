%%
in:	'\n'
	| cmd
cmd:	'D'points';'
points:	point
		|points'-''-'point
point:	cart
		| pol
cart:	'('exp','exp')'
pol:	'('exp':'exp')'
exp:	nb
		| '('nb'+'nb')'
		| '('nb'-'nb')'
		| '('nb'*'nb')'
		| '('nb'/'nb')'
nb:	"bah c'est un nombre quoi..."
;
