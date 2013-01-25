
import com.sun.net.httpserver { HttpServer { createHttpServer=create }, HttpHandler, HttpExchange, Headers }
import java.net { InetSocketAddress,
    HttpURLConnection { httpOk= \iHTTP_OK, httpBadRequest=\iHTTP_BAD_REQUEST },
	URLDecoder { urlDecode = decode }
}
import java.io { OutputStream }
import ceylon.interop.java { javaString }
import java.text { SimpleDateFormat, DateFormat }
import java.util { Date }
import java.lang { Thread { sleep } }

DateFormat dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

shared class Handler() satisfies HttpHandler {

	String? getActualResponse(String? queryValue) {
		if (is String queryValue) {
			for (fixResponse in fixResponses) {
				if (fixResponse.key == urlDecode(queryValue)) {
					return fixResponse.item;
				}
			}
		}
		return null;
	}


	shared actual void handle(HttpExchange httpExchange) {
		logRequest(httpExchange);
		String? query = httpExchange.requestURI.rawQuery;
		if (is String query) {
			String? response = getActualResponse(query.split("=").last);
			if (is String response) {
				sendResponse(httpExchange, response);
				return;
			}
		}
		sendResponse(httpExchange, "I can't response to your query", httpBadRequest);
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

