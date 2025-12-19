package com.example.demo

import kotlinx.html.*
import kotlinx.html.dom.createHTMLDocument
import kotlinx.html.dom.serialize
import kotlinx.html.stream.createHTML
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import java.util.*

const val WELCOME_MESSAGE_ROUTE = "/welcome-message"
const val TEXT_HTML_UTF8 = "${MediaType.TEXT_HTML_VALUE};charset=UTF-8"
const val HX_GET = "hx-get"

@RestController("/")
class HelloController {
    @GetMapping("/", produces = [TEXT_HTML_UTF8])
    fun index(): String {
        val num = Math.random() * 100

        val doc = createHTMLDocument().html {
            head {
                title { +"kotlinx.html + htmx demo" }
                htmxScript()
                inlineStyles()
            }
            body {
                div { welcomeMessageWithNumber(num) }
            }
        }
        return doc.serialize()
    }

    @GetMapping(WELCOME_MESSAGE_ROUTE, produces = [TEXT_HTML_UTF8])
    fun welcomeMessage(): String = createHTML().div {
        val num = Math.random() * 100
        welcomeMessageWithNumber(num)
    }

    @GetMapping("/json")
    fun jsonReturn(): String {
        return "Hello World"
    }
}

fun HEAD.htmxScript() {
    script {
        src = "https://unpkg.com/htmx.org@1.9.5"
        integrity = "sha384-xcuj3WpfgjlKF+FXhSQFQ0ZNr39ln+hwjN3npfM9VBnUskLolQAcN80McRIVOPuO"
        attributes["crossorigin"] = "anonymous"
    }
}

fun HEAD.inlineStyles() {
    style {
        +"div.red-border { border: 1px solid red; }"
    }
}

fun DIV.welcomeMessageWithNumber(num: Double) {
    attributes["class"] = "red-border"
    attributes[HX_GET] = WELCOME_MESSAGE_ROUTE
    attributes["hx-swap"] = "outerHTML"
    p {
        +"Hello from kotlinx.html + htmx demo! "
    }
    p {
        +"Here's a random number: "
        +String.format(Locale.ROOT, "%.0f", num)
    }
    p {
        +"(Click me for a new random number!!)"

    }
    button { +"button" }
}
