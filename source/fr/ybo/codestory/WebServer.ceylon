
import com.sun.net.httpserver { HttpServer { createHttpServer=create }, HttpHandler, HttpExchange, Headers }
import java.net { InetSocketAddress,
    HttpURLConnection { httpOk= \iHTTP_OK }
}
import java.io { OutputStream }
import ceylon.interop.java { javaString }
import java.text { SimpleDateFormat, DateFormat }
import java.util { Date }
import java.lang { Thread { sleep } }

DateFormat dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

class Handler() satisfies HttpHandler {


	shared actual void handle(HttpExchange httpExchange) {
		logRequest(httpExchange);
		sendResponse(httpExchange, "ybonnel@gmail.com");
	}

	void sendResponse(HttpExchange httpExchange, String response, Integer status = httpOk) {
 		Headers headers = httpExchange.responseHeaders;
        headers.set("Content-Type", "text/html;charset=UTF-8");
        httpExchange.sendResponseHeaders(status, response.size);
        OutputStream os = httpExchange.responseBody;
        os.write(javaString(response).getBytes("UTF-8"));
        os.close();	
		logResponse(response, status);
	}

	void logRequest(HttpExchange exchange) {
		print("" dateFormat.format(Date()) ":" exchange.requestMethod ":" exchange.requestURI.string "");
	}

	void logResponse(String response, Integer status) {
		print("" dateFormat.format(Date()) ":" status ":" response "");
	}
}

shared void startServer() {
	HttpServer server = createHttpServer(InetSocketAddress(8080), 0);
	server.createContext("/", Handler());
	server.executor := null;
    // Start to accept incoming connections
	print("" dateFormat.format(Date()) ":CodeStory-server:Starting");
    server.start();
	while (true) {
		// Attente infinie.
		sleep(60000);
	}
}


