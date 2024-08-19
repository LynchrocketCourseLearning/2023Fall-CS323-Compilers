import java.io.File
import java.nio.file.Files
import java.nio.file.Paths

fun main(args: Array<String>) {
    val lines = Files.readAllLines(Paths.get("./src/main/resources/test_file/${args[0]}"), Charsets.UTF_8)
    for (line in lines) {
        if (!scan(line)) {
            break
        }
    }
    tokens.forEach { castToken(it) }

    val expected = Files.readAllLines(Paths.get("./src/main/resources/test_result/${args[0]}.res"), Charsets.UTF_8)
    val expectedOutput = expected[0].split(":")[1]
    val realOutput = result.joinToString("").trim()
    val success = (expectedOutput == realOutput)
    val resultText = "Expected:$expectedOutput\nReal:$realOutput\n====================\nTest Result:$success"
    File("./src/main/resources/test_result/${args[0]}.res").writeText(resultText)
    print(resultText)
}

val keywords = setOf(
    "boolean",
    "byte",
    "char",
    "short",
    "int",
    "long",
    "float",
    "double",
    "void",
    "assert",
    "class",
    "enum",
    "abstract",
    "interface",
    "default",
    "extends",
    "implements",
    "final",
    "static",
    "import",
    "package",
    "native",
    "new",
    "private",
    "protected",
    "public",
    "instanceof",
    "super",
    "synchronized",
    "this",
    "throw",
    "throws",
    "try",
    "catch",
    "finally",
    "volatile",
    "if",
    "else",
    "switch",
    "case",
    "do",
    "while",
    "for",
    "continue",
    "break",
    "return",
    "strictfp",
    "transient"
)
val types = setOf("boolean", "byte", "char", "short", "int", "long", "float", "double", "void")
val digit = '0'..'9'
val letter = 'a'..'z' union 'A'..'Z' union setOf('_', '$')
val identifiers = mutableListOf<String>()
val tokens = mutableListOf<Token>()
val result = mutableListOf<String>()

fun scan(line: String): Boolean {
    var idx = 0
    while (idx < line.length) {
        if (tokens.isNotEmpty() && tokens.last().value in types && line[idx] !in letter union setOf(' ')) {
            tokens.add(Token(TokenType.Error))
            return false
        }
        when (line[idx]) {
            ' ', '\n', '\t' -> {
                idx++
            }

            in digit union setOf('+', '-') -> {
                var isInt = true
                val stIdx = idx++
                while (idx < line.length && line[idx] in digit union setOf('.', 'E')) {
                    if (line[idx] in setOf('.', 'E')) {
                        isInt = false
                    }
                    idx++
                }
                val number = line.substring(stIdx, idx)
                tokens.add(Token(if (isInt) TokenType.Integer else TokenType.Float, number))
            }

            in letter -> {
                val stIdx = idx++
                while (idx < line.length && line[idx] in letter union digit) {
                    idx++
                }
                val word = line.substring(stIdx, idx)
                if (word in keywords) {
                    tokens.add(Token(TokenType.Keyword, word))
                } else {
                    if (tokens.isEmpty() || (word !in identifiers && tokens.last().value !in types)) {
                        tokens.add(Token(TokenType.Error))
                        return false
                    }
                    tokens.add(Token(TokenType.Identifier, word))
                    identifiers.add(word)
                    while (idx < line.length && line[idx] == ' ') {
                        idx++
                    }
                    if (idx < line.length && (line[idx] == '+' || line[idx] == '-')) {
                        tokens.add(Token(TokenType.ArithOp, line[idx].toString()))
                        idx++
                    }
                }
            }

            ';', '(', ')', '{', '}' -> {
                tokens.add(Token(TokenType.Separator, line[idx].toString()))
                idx++
            }

            '*', '/', '%' -> {
                tokens.add(Token(TokenType.ArithOp, line[idx].toString()))
                idx++
            }

            '<', '>', '!', '=' -> {
                val stIdx = idx++
                while (idx < line.length && line[idx] == ' ') {
                    idx++
                }
                if (idx < line.length && line[idx] == '=') {
                    tokens.add(Token(TokenType.RelOp, "${line[stIdx]}${line[idx]}"))
                    idx++
                } else {
                    if (line[stIdx] == '<' || line[stIdx] == '>') {
                        tokens.add(Token(TokenType.RelOp, line[stIdx].toString()))
                    } else if (line[stIdx] == '=') {
                        tokens.add(Token(TokenType.ArithOp, "="))
                    } else {
                        tokens.add(Token(TokenType.LogicOp, "!"))
                    }
                }
            }

            else -> {
                tokens.add(Token(TokenType.Error))
                return false
            }
        }
    }
    return true
}

fun castToken(token: Token) {
    when (token.tokenType) {
        TokenType.Keyword -> when (token.value) {
            "boolean", "byte", "char", "short", "int", "long", "float", "double", "void" -> result.add("TYPE ")
            "while" -> result.add("WHILE ")
            "for" -> result.add("FOR ")
            "if" -> result.add("IF ")
            "else" -> result.add("ELSE ")
            "return" -> result.add("RET ")
            else -> result.add("${token.value.uppercase()} ")
        }

        TokenType.Identifier -> result.add("ID ")
        TokenType.Separator -> when (token.value) {
            ";" -> result.add("SEMI ")
            "(" -> result.add("LP ")
            ")" -> result.add("RP ")
            "{" -> result.add("LC ")
            "}" -> result.add("RC ")
        }

        TokenType.Integer -> result.add("INT ")
        TokenType.Float -> result.add("FLOAT ")
        TokenType.RelOp -> when (token.value) {
            "<" -> result.add("LT ")
            "<=" -> result.add("LE ")
            ">" -> result.add("GT ")
            ">=" -> result.add("GE ")
            "!=" -> result.add("NE ")
            "==" -> result.add("EQ ")
        }

        TokenType.ArithOp -> when (token.value) {
            "=" -> result.add("ASSIGN ")
            "+" -> result.add("PLUS ")
            "-" -> result.add("MINUS ")
            "*" -> result.add("MULTIPLY ")
            "/" -> result.add("DIVIDE ")
            "%" -> result.add("REMIND ")
        }

        TokenType.LogicOp -> when (token.value) {
            "!" -> result.add("NOT ")
            "&&" -> result.add("AND ")
            "||" -> result.add("OR ")
        }

        TokenType.Error -> result.add("ERROR ")
    }
}