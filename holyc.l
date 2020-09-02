%{
#include <string>
#include <limits.h>
using namespace std;

/* Get our custom yyFlexScanner subclass */
#include "scanner.hpp"
#include "tokens.hpp"
#undef  YY_DECL
#define YY_DECL int holyc::Scanner::yylex( holyc::Parser::semantic_type * const lval )

/* define yyterminate as this instead of NULL */
#define yyterminate() return( TokenKind::END )

/* Exclude unistd.h for Visual Studio compatability. */
#define YY_NO_UNISTD_H

/* typedef to make the reference to token kinds shorter */
using TokenKind = holyc::Parser::token;

%}

%option debug
%option nodefault
%option yyclass="holyc::Scanner"
%option noyywrap
%option c++

DIGIT [0-9]
LETTER [a-zA-z]
ID ({LETTER}|_)+({LETTER}|{DIGIT}|_)*
%%
%{          /** Code executed at the beginning of yylex **/
            yylval = lval;
%}

"+"		{
		// Keep track of the "kind" of token we matched. In this case,
		// it's a CROSS (aka the plus symbol). The full list of token
		// kinds is declared around line 197 of grammar.hh. The testing
		// functionScanner::outputTokens also indicates what each token
		// represents (declared in scanner.cpp line 9)
		int tokenKind = TokenKind::CROSS;

		//Instatiate a token. There are 4 classes of tokens defined based on
		// - a literal string (StringLitToken)
		// - a literal integer (IntLitToken)
		// - an identifier (IDToken)
		// - a base Token (any other type)
		// The token object is a handy place to keep information about the
		// token (i.e. token metadata) such as the line and column on which
		// the token character started (which can be used later in debug
		// messages, etc).
		Token * token = new Token(lineNum, colNum, tokenKind);

		//Assign the token to a instance variable of the scanner.
		// (When Flex processes a .l file in C++ mode, it creates
		// a class called Scanner, which is a subclass of yyFlexScanner)
		// By assigning a value to this field, we put the token
		// metadata in a place where scanner's client program can find it.
		this->yylval->tokenValue = token;

		//Since we consumed 1 character, increase the column number by 1
		colNum++;

		//Let the scanner's client program know that a CROSS token
		// has been matched
		return tokenKind;
		}

"-" {
		//Essentially the same thing as CROSS, but without the verbose
		// comments so it doesn't look so scary.
		int tokenKind = TokenKind::DASH;
		this->yylval->tokenValue = new Token(lineNum, colNum, tokenKind);
		colNum++;
		return tokenKind;
		}

{DIGIT}+	{
		//TODO: The following computation of the integer
		// value does not check for overflow. It should do so.
		int intVal = atoi(yytext);

		if(intVal > INT_MAX) {
        std::string msg = "Integer literal too large; using max value";
        error(lineNum, colNum, msg);
      	intVal = INT_MAX;
    	}

		//Note that the IntLitToken does not take a TokenKind argument
		// since it's implicitly known that the token represents an
		// INTLITERAL
		yylval->tokenValue = new IntLitToken(lineNum, colNum, intVal);

		//TODO: update the colNum count according to the number of
		// characters consumed.

		// I ADDED HRERE
		//colNum++;
    colNum += strlen(yytext);

		//As before, alert the client program that an INTLITERAL
		// token was matched
		return TokenKind::INTLITERAL;
		}


\n		{
		//Update the line number, reset the columnNumber
		lineNum++;
		colNum = 1;
		}


"^"   {
    int tokenKind = TokenKind::CARAT;
    this->yylval->tokenValue = new Token(lineNum, colNum, 264);
    colNum++;
    return 264;
    }


"["   {
    int tokenKind = TokenKind::LBRACE;
    this->yylval->tokenValue = new Token(lineNum, colNum, 284);
    colNum++;
    return 284;
    }


"]"   {
    int tokenKind = TokenKind::RBRACE;
    this->yylval->tokenValue = new Token(lineNum, colNum, 293);
    colNum++;
    return 293;
    }


bool {
  	 int tokenKind = TokenKind::BOOL;
  	 this->yylval->tokenValue = new Token(lineNum, colNum, 262);
  	 colNum+=4;
  	 return 262;
  }


boolptr {
  	 int tokenKind = TokenKind::BOOLPTR;
  	 this->yylval->tokenValue = new Token(lineNum, colNum, 263);
  	 colNum+=7;
  	 return 263;
  }


CHAR {
  	 int tokenKind = TokenKind::CHAR;
  	 this->yylval->tokenValue = new Token(lineNum, colNum, 265);
  	 colNum += 4;
  	 return 265;
  }


CHARPTR {
  	 int tokenKind = TokenKind::CHARPTR;
  	 this->yylval->tokenValue = new Token(lineNum, colNum, 267);
  	 colNum += 7;
     return 267;
  }


else {
  	 int tokenKind = TokenKind::ELSE;
  	 this->yylval->tokenValue = new Token(lineNum, colNum, 273);
  	 colNum+=4;
  	 return 273;
  }

FALSE {
  	int tokenKind = TokenKind::FALSE;
  	this->yylval->tokenValue = new Token(lineNum, colNum, 275);
  	colNum+=5;
  	return 275;
  }


FROMCONSOLE {
  	int tokenKind = TokenKind::FROMCONSOLE;
  	this->yylval->tokenValue = new Token(lineNum, colNum, 276);
  	colNum+=11;
  	return 276;
  }


if {
  	int tokenKind = TokenKind::IF;
  	this->yylval->tokenValue = new Token(lineNum, colNum, 278);
  	colNum+=2;
  	return 278;
  }


INTPTR {
  	int tokenKind = TokenKind::INTPTR;
  	this->yylval->tokenValue = new Token(lineNum, colNum, 281);
  	colNum += 6;
  	return 281;
}


NULLPTR {
	  int tokenKind = TokenKind::NULLPTR;
	  this->yylval->tokenValue = new Token(lineNum, colNum, 291);
	  colNum+=7;
	  return 291;
}


TOCONSOLE {
	  int tokenKind = TokenKind::TOCONSOLE;
	  this->yylval->tokenValue = new Token(lineNum, colNum, 301);
	  colNum+=9;
	  return 301;
}


true {
	  int tokenKind = TokenKind::TRUE;
	  this->yylval->tokenValue = new Token(lineNum, colNum, 302);
	  colNum+=4;
	  return 302;
}


void {
	  int tokenKind = TokenKind::VOID;
	  this->yylval->tokenValue = new Token(lineNum, colNum, 303);
	  colNum += 4;
	  return 303;
}


while {
	  int tokenKind = TokenKind::WHILE;
	  this->yylval->tokenValue = new Token(lineNum, colNum, 304);
	  colNum+=5;
	  return 304;
}


return {
	int tokenKind = TokenKind::RETURN;
	this->yylval->tokenValue = new Token(lineNum, colNum, 295);
	colNum += 6;
	return 295;
}


{ID}  {
      //ID has to be the last sequence or it gunna replace strings above. e.g "void", "if", "while"
      //If ID is put above, it would cause the error: rule doesn't match
      this->yylval->tokenValue = new IDToken(lineNum, colNum, yytext);
      colNum += yyleng;
      return TokenKind::ID;
  }


"&&" {
	int tokenKind = TokenKind::AND;
	this->yylval->tokenValue = new Token(lineNum, colNum, 258);
	colNum+=2;
	return 258;
}


"&" {
	int tokenKind = TokenKind::AMP;
	this->yylval->tokenValue = new Token(lineNum, colNum, 259);
	colNum++;
	return 259;
}


"=" {
	int tokenKind = TokenKind::ASSIGN;
	this->yylval->tokenValue = new Token(lineNum, colNum, 260);
	colNum++;
	return 260;
}


"@" {
	int tokenKind = TokenKind::AT;
	this->yylval->tokenValue = new Token(lineNum, colNum, 261);
	colNum++;
	return 261;
}


"," {
	int tokenKind = TokenKind::COMMA;
	this->yylval->tokenValue = new Token(lineNum, colNum, 268);
	colNum++;
	return 268;
}


"++" {
	int tokenKind = TokenKind::CROSSCROSS;
	this->yylval->tokenValue = new Token(lineNum, colNum, 270);
	colNum+=2;
	return 270;
}


"--" {
	int tokenKind = TokenKind::DASHDASH;
	this->yylval->tokenValue = new Token(lineNum, colNum, 272);
	colNum+=2;
	return 272;
}


"==" {
	int tokenKind = TokenKind::EQUALS;
	this->yylval->tokenValue = new Token(lineNum, colNum, 274);
	colNum+=2;
	return 274;
}


">" {
	int tokenKind = TokenKind::GREATER;
	this->yylval->tokenValue = new Token(lineNum, colNum, 282);
	colNum++;
	return 282;
}


">=" {
	int tokenKind = TokenKind::GREATEREQ;
	this->yylval->tokenValue = new Token(lineNum, colNum, 283);
	colNum+=2;
	return 283;
}


"{" {
	int tokenKind = TokenKind::LCURLY;
	this->yylval->tokenValue = new Token(lineNum, colNum, 285);
	colNum++;
	return 285;
}


"<" {
	int tokenKind = TokenKind::LESS;
	this->yylval->tokenValue = new Token(lineNum, colNum, 286);
	colNum++;
	return 286;
}


"<=" {
	int tokenKind = TokenKind::LESSEQ;
	this->yylval->tokenValue = new Token(lineNum, colNum, 287);
	colNum+=2;
	return 287;
}


"(" {
	int tokenKind = TokenKind::LPAREN;
	this->yylval->tokenValue = new Token(lineNum, colNum, 288);
	colNum++;
	return 288;
}


"!" {
	int tokenKind = TokenKind::NOT;
	this->yylval->tokenValue = new Token(lineNum, colNum, 289);
	colNum++;
	return 289;
}


"!=" {
	int tokenKind = TokenKind::NOTEQUALS;
	this->yylval->tokenValue = new Token(lineNum, colNum, 290);
	colNum+=2;
	return 290;
}


"||" {
	int tokenKind = TokenKind::OR;
	this->yylval->tokenValue = new Token(lineNum, colNum, 292);
	colNum+=2;
	return 292;
}


"}" {
	int tokenKind = TokenKind::RCURLY;
	this->yylval->tokenValue = new Token(lineNum, colNum, 294);
	colNum++;
	return 294;
}


")" {
	int tokenKind = TokenKind::RPAREN;
	this->yylval->tokenValue = new Token(lineNum, colNum, 296);
	colNum++;
	return 296;
}


";" {
	int tokenKind = TokenKind::SEMICOLON;
	this->yylval->tokenValue = new Token(lineNum, colNum, 297);
	colNum++;
	return 297;
}


"/" {
	int tokenKind = TokenKind::SLASH;
	this->yylval->tokenValue = new Token(lineNum, colNum, 298);
	colNum++;
	return 298;
}


"*" {
	int tokenKind = TokenKind::STAR;
	this->yylval->tokenValue = new Token(lineNum, colNum, 299);
	colNum++;
	return 299;
}


.   {
		//TODO: Add the rest of the rules above this point so that legal characters
		// are properly accounted for.
		std::string msg = "Illegal character ";
		msg += yytext;
		error(lineNum,colNum,msg);
		colNum += yyleng;
    }


['](.|\\n|\\[ \t]|\\t|\\s|\\\\) {

      // This is Char literal. 'a or 'B
    	return this->makeCharLitToken(yytext);
    }



[\"]([^\\\"\n]|\\[nt\'\"\\])*[\"]	{

      //This is String Literal
    	yylval->tokenValue = new StrToken(lineNum, colNum, yytext);
    	colNum += yyleng;
    	return TokenKind::STRLITERAL;
    }

%%
