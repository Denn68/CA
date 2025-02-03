%{
open Ast
%}

%token MUL, DIV, PLUS, MINUS, LT, EQ, GT, AND, OR, NOT, LPAREN, RPAREN, COMMA, EOL
%token PRINT
%token<int> INTEGER
%token<string> VAR
%token<int> BOOLEAN
%start calc
%type <Ast.inst> calc
%type <Ast.expr> expr
%type <Ast.expr> term
%type <Ast.expr> factor
%type <Ast.inst> inst

%%

calc : inst EOL                { $1 } ;

expr : expr PLUS expr       { Add($1, $3) }
     | expr MINUS expr      { Sub($1, $3) }
     | expr LT expr         { LessThan($1, $3) }
     | expr EQ expr         { Equal($1, $3) }
     | expr GT expr         { GreaterThan($1, $3) }
     | expr AND expr        { And($1, $3) }
     | expr OR expr         { Or($1, $3) }
     | NOT expr             { Not($2) }
     | VAR                  { Var($1) }
     | BOOLEAN              { Boolean($1) }
     | term                 { $1 };

inst: PRINT exprs      {Print($2)}
      ;

exprs: expr COMMA         {[$1]}
     | expr COMMA exprs   {$1::$3}
     ;

term : term MUL term        { Mul($1, $3) }
     | term DIV term        { Div($1, $3) }
     | factor               { $1 } ;

factor : INTEGER            { Integer($1) }
       | VAR                { Var($1)}
       | BOOLEAN            { Boolean($1)}
       | LPAREN expr RPAREN { $2 } ;

%%
