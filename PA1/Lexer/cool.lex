/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    // Opened multiline comment parentheses counter
    int parenthesesCounter = 0;
    
    // Compiler test
    boolean fakeflag = false;

    private int curr_lineno = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yy_lexical_state) {
    case YYINITIAL:
	/* nothing special to do in the initial state */
	break;
	 If necessary, add code for other states here, e.g:
	   case COMMENT:
	   ...
	   break;
	case STRING:
		yybegin(YYINITIAL);
 		return new Symbol(TokenConstants.ERROR,"EOF in string constant"); 
 	case MLCOMMENT: 
 		yybegin(YYINITIAL); 
 		return new Symbol(TokenConstants.ERROR, "EOF in comment"); 
 	case STRING_ERROR: 
         yybegin(YYINITIAL); 
         return new Symbol(TokenConstants.ERROR, "EOF in string constant");     
     } 
     return new Symbol(TokenConstants.EOF); 
 %eofval} 

 %class CoolLexer 
 %cup 

 %state STRING,MLCOMMENT,STRING_ERROR,OLCOMMENT 
/* MLCOMMENT - multiline comment, OLCOMMENT - oneline comment*/

 NewLineno        = \n|\r|\r\n 
 WhiteSpace       = [\ \r\v\t\n\f]  
 ObjectIdentifier = [a-z]([a-zA-Z0-9_]*) 
 TypeIdentifier   = [A-Z]([a-zA-Z0-9_]*) 
 DecimalInt       = ([0-9]+) 

/* %% */
 
  <YYINITIAL>{


/* Keywords are case-insensitive except for the values true and false which must begin with a lower-case letter. */
          
           [cC][lL][aA][sS][sS]                           { return new Symbol(TokenConstants.CLASS); }
           [iI][fF]                                       { return new Symbol(TokenConstants.IF); }
 	   [fF][iI]                                       { return new Symbol(TokenConstants.FI); } 
           [eE][lL][sS][eE]                               { return new Symbol(TokenConstants.ELSE); } 
 	   f[aA][lL][sS][eE]                              { return new Symbol(TokenConstants.BOOL_CONST, java.lang.Boolean.FALSE); }
 	   t[rR][uU][eE]                                  { return new Symbol(TokenConstants.BOOL_CONST, java.lang.Boolean.TRUE); } 
 	   [iI][nN][hH][eE][rR][iI][tT][sS]               { return new Symbol(TokenConstants.INHERITS); }
 	   [iI][sS][vV][oO][iI][dD]                       { return new Symbol(TokenConstants.ISVOID); } 
 	   [lL][oO][oO][pP]                               { return new Symbol(TokenConstants.LOOP); }
 	   [pP][oO][oO][lL]                               { return new Symbol(TokenConstants.POOL); }
 	   [tT][hH][eE][nN]                               { return new Symbol(TokenConstants.THEN); }
 	   [iI][nN]                                       { return new Symbol(TokenConstants.IN); } 
 	   [wW][hH][iI][lL][eE]                           { return new Symbol(TokenConstants.WHILE); } 
 	   [cC][aA][sS][eE]                               { return new Symbol(TokenConstants.CASE); }
 	   [eE][sS][aA][cC]                               { return new Symbol(TokenConstants.ESAC); }
 	   [oO][fF]                                       { return new Symbol(TokenConstants.OF); } 
 	   [nN][oO][tT]                                   { return new Symbol(TokenConstants.NOT); } 
 	   [lL][eE][tT]                                   { return new Symbol(TokenConstants.LET); } 
 	   [nN][eE][wW]                                   { return new Symbol(TokenConstants.NEW); } 


    /*Operators*/

	   "=>"		                   { return new Symbol(TokenConstants.DARROW); } 
 	   "<="                            { return new Symbol(TokenConstants.LE);} 
 	   "<-" 	                   { return new Symbol(TokenConstants.ASSIGN);} 

 	   "+"                             { return new Symbol(TokenConstants.PLUS);} 
 	   "-"                             { return new Symbol(TokenConstants.MINUS);} 
 	   "/"                             {return new Symbol(TokenConstants.DIV);} 
 	   "*"                             {return new Symbol(TokenConstants.MULT);} 
	   "="                             { return new Symbol(TokenConstants.EQ);} 

 	   "<"                             { return new Symbol(TokenConstants.LT);}
 	   "."                             { return new Symbol(TokenConstants.DOT);} 
 	   ","                             { return new Symbol(TokenConstants.COMMA);} 
 	   ";"                             { return new Symbol(TokenConstants.SEMI);} 
 	   ":"                             { return new Symbol(TokenConstants.COLON);}
 	   "~"                             { return new Symbol(TokenConstants.NEG);}
 	   "@" 	                           { return new Symbol(TokenConstants.AT);} 

 	   ")"                             { return new Symbol(TokenConstants.LPAREN);} 
 	   "("                             { return new Symbol(TokenConstants.RPAREN);} 
 	   "{"                             { return new Symbol(TokenConstants.LBRACE);} 
 	   "}"                             { return new Symbol(TokenConstants.RBRACE);} 


	   .                               {System.err.println("LEXER BUG - UNMATCHED: " + yytext()); } 

 	   /*Comment rules*/
 	   "(*"		 { parenthesesCounter++; yybegin(MLCOMMENT); } 
 	   "*)"		 { return new Symbol(TokenConstants.ERROR, "Unmatched *)"); } 
 	   "--"		 { curr_lineno++; yybegin(OLCOMMENT); } 


 {WhiteSpace} { /\*Do nothing*\/ }

 {ObjectIdentifier} { return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext())); } 
	
/*TypeID Rule */
 {TypeIdentifier} { return new Symbol(TokenConstants.TYPEID,AbstractTable.idtable.addString(yytext())); } 
	
/*Integer Rule*/
 {DecimalInt} { return new Symbol(TokenConstants.INT_CONST, AbstractTable.idtable.addString(yytext())); } 

 } 

 <STRING>{ 
 	\"				{	yybegin(YYINITIAL); 
 						if(string_buf.length() == MAX_STR_CONST) 
 							return new Symbol(TokenConstants.ERROR, "String constant too long"); 
 						return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(string_buf.toString())); 
 					} 
 	\\t						{ string_buf.append('\t'); }
 	\\n						{ string_buf.append('\n'); }
 	\\b						{ string_buf.append('\b'); }
 	\\f						{ string_buf.append('\f'); } 
 	\\.						{ string_buf.append(yytext().substring(1,yytext().length())); 
 							  if(string_buf.length() > MAX_STR_CONST){ 
 									yybegin(STRING_ERROR); 
 									return new Symbol(TokenConstants.ERROR, "String constant too long"); 
 							  } 
 							} 
 	\\\n					{ string_buf.append(yytext().substring(1,yytext().length()));  
 							  curr_lineno++;  
 							  if(string_buf.length() > MAX_STR_CONST){ 
 									yybegin(STRING_ERROR);
 									return new Symbol(TokenConstants.ERROR, "String constant too long"); 
 							  } 
 							} 
 	\n 						{ curr_lineno++; yybegin(YYINITIAL);
 	                                                    return new Symbol(TokenConstants.ERROR, "Unterminated string constant"); }
 	"(*"					{ string_buf.append("(*"); }
	  "*)"					{ string_buf.append("*)"); }
	  "--"					{ string_buf.append("--"); }
 	.                                       {string_buf.append(yytext());  
  	 							if(string_buf.length() > MAX_STR_CONST ){ 
  	 								yybegin(STRING_ERROR); 
     								return new Symbol(TokenConstants.ERROR, "String constant too long"); 
  								} 
	                                         }  
  } 
 <STRING_ERROR>{  
 	\" 					{ yybegin(YYINITIAL); } 
 	\n 					{ curr_lineno++; yybegin(YYINITIAL); } 
 	\\\n				{ curr_lineno++;} 
	\\. | .				{}
}
/\*Multiline comments state*\/
<MLCOMMENT>{
	\n						{ curr_lineno++; }
	"(*" 					{  parenthesesCounter++;}
	"*)"				    { parenthesesCounter--; if(parenthesesCounter == 0) yybegin(YYINITIAL);}
	.                       {}
}
/*Oneline comments state*/
<OLCOMMENT>{
	\n|\r|\r\n				{ yybegin(YYINITIAL); }
	.						{}
}
© 2022 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
