data class Token(val tokenType: TokenType, val value: String = "")

sealed class TokenType {
    data object Keyword : TokenType()
    data object Identifier : TokenType()
    data object Separator : TokenType()
    data object Integer : TokenType()
    data object Float : TokenType()
    data object RelOp : TokenType()
    data object ArithOp : TokenType()
    data object LogicOp : TokenType()
    data object Error : TokenType()
}

// 这个没用，可以删掉
enum class T(val typeName: String) {
    // separator
    SEMI(";"),
    LP("("),
    RP(")"),
    LC("{"),
    RC("}"),

    // relop
    LT("<"),
    LE("<="),
    GT(">"),
    GE(">="),
    NE("!="),
    EQ("=="),

    // arithop
    ASSIGN("="),
    PLUS("+"),
    MINUS("-"),
    MULTIPLY("*"),
    DIVIDE("/"),
    REMIND("%"),

    // logicOp
    NOT("!"),
    AND("&&"),
    OR("||"),

    // type
    BOOLEAN("boolean"),
    BYTE("byte"),
    CHAR("char"),
    SHORT("short"),
    INT("int"),
    LONG("long"),
    FLOAT("float"),
    DOUBLE("double"),
    VOID("void"),

    // keywords
    ASSERT("assert"),

    CLASS("class"),
    ENUM("enum"),
    ABSTRACT("abstract"),
    INTERFACE("interface"),
    DEFAULT("default"),
    EXTENDS("extends"),
    IMPLEMENTS("implements"),

    FINAL("final"),
    STATIC("static"),

    IMPORT("import"),
    PACKAGE("package"),

    NATIVE("native"),
    NEW("new"),
    PRIVATE("private"),
    PROTECTED("protected"),
    PUBLIC("public"),

    INSTANCEOF("instanceof"),
    SUPER("super"),
    SYNC("synchronized"),
    THIS("this"),
    THROW("throw"),
    THROWS("throws"),

    TRY("try"),
    CATCH("catch"),
    FINALLY("finally"),
    VOLATILE("volatile"),

    IF("if"),
    ELSE("else"),
    SWITCH("switch"),
    CASE("case"),
    DO("do"),
    WHILE("while"),
    FOR("for"),
    CONT("continue"),
    BREAK("break"),
    RET("return"),

    STRICTFP("strictfp"),
    TRAN("transient"),
}