%{
  //codigo JS
  const Tipo = require('./simbolo/Tipo')
  const Nativo = require('./expresiones/Nativo')
  const Aritmeticas = require('./expresiones/Aritmeticas') 
%}



// ################### ANALIZADOR LEXICO #######################
%lex
%options case-insensitive 

// ---------> Expresiones Regulares
entero  [0-9]+;


%%
// -----> Reglas Lexicas





//-------------------- OPERADORES ARITMETICOS----------------------//

"+"                     return 'MAS'



";"                     return 'PUNTOCOMA'

"("                     return 'PAR1'
")"                     return 'PAR2'
[0-9]+"."[0-9]+         return 'DECIMAL'
[0-9]+                  return 'ENTERO'



[\"]([^\"\n])*[\"]  {yytext=yytext.substr(1,yyleng-2);
                    return 'CADENA';}   /Aqui es donde se quita las comillas de la cadena y presentpo el comentario

// -----> Espacios en Blanco
[ \s\r\n\t]             {/* Espacios se ignoran */}
[\ \n]              {};

// -----> FIN DE CADENA Y ERRORES
<<EOF>>               return 'EOF';
.  { console.error('Error léxico: \"' + yytext + '\", linea: ' + yylloc.first_line + ', columna: ' + yylloc.first_column);  }


/lex
// ################## ANALIZADOR SINTACTICO ######################
// -------> Precedencia

%left 'MAS'
//%right 'UMENOS'

// -------> Simbolo Inicial

%start inicio


%% // ------> Gramatica

inicio : instrucciones EOF                  {return $1;}
;

instrucciones : instrucciones instruccion   {$1.push($2); $$ = $1;}
              | instruccion                 {$$ = [$1];}
;

instruccion : expresion PUNTOCOMA   {$$ = $1;}
;

expresion : expresion MAS expresion   {$$ = new Aritmeticas.default(Aritmeticas.Operadores.SUMA,@1.first_line, @1.first_column,$1,$3);}
		  |	PAR1 EXPRESION PAR2       {$$ = $2;}
          | ENTERO                    {$$ = new Nativo.default(new Tipo.default(Tipo.tipoDato.ENTERO), $1,@1.first_line, @1.first_column);}
          | DECIMAL                   {$$ = new Nativo.default(new Tipo.default(Tipo.tipoDato.DECIMAL), $1,@1.first_line, @1.first_column);}
;