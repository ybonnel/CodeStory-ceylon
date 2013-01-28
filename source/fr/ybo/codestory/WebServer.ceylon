
import com.sun.net.httpserver { HttpServer { createHttpServer=create }, HttpHandler, HttpExchange, Headers }
import java.net { InetSocketAddress,
    HttpURLConnection { httpOk= \iHTTP_OK, httpBadRequest=\iHTTP_BAD_REQUEST, httpCreated=\iHTTP_CREATED },
	URLDecoder { urlDecode = decode }
}
import java.io { OutputStream, InputStream, BufferedReader, InputStreamReader }
import ceylon.interop.java { javaString }
import java.text { SimpleDateFormat, DateFormat }
import java.util { Date }
import java.lang { Thread { sleep } }
import java.util.regex { Pattern { compile } } 

DateFormat dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

shared class Handler() satisfies HttpHandler {

	Pattern calculatePattern = compile("[\\(\\)0-9\\+/\\* ,\\-]+");

	String? getActualResponse(String? queryValue) {
		if (is String queryValue) {
			String queryDecode = urlDecode(queryValue);
			for (fixResponse in fixResponses) {
				if (fixResponse.key == queryDecode) {
					return fixResponse.item;
				}
			}
			if (calculatePattern.matcher(javaString(queryDecode)).matches()) {
				return Calculate().calculate(queryDecode);
			}
		}
		return null;
	}

	class Response(response, status = httpOk, contentType = "text/html;charset=UTF-8") {
		shared String response;
		shared Integer status;
		shared String contentType; 
	}

	Response? handleQuery(String? query) {
		if (is String query) {
			String? response = getActualResponse(query.split("=").last);
			if (is String response) {
				return Response(response);
			}
		}
		return null;
	}

	Response? handlePath(String path, String payload) {
		if (path.startsWith("/jajascript/optimize")) {
			return Response(getJajascriptResponse(payload),httpOk, 
				"application/json");
		}
		if (path.startsWith("/scalaskel/change/")) {
			Integer? change = parseInteger(path.split("/").last else "0");
			return Response(toJson(Scalaskel().calculate(change else 0)));
		}
		if (path.startsWith("/enonce/")) {
			return Response("OK", httpCreated);
		}
		return null;
	}

	String getPayload(InputStream stream) {
		StringBuilder builder = StringBuilder();
		BufferedReader reader = BufferedReader(InputStreamReader(stream));
		variable String? ligne := reader.readLine();
		while (is String l = ligne) {
			builder.append(l);
			builder.append('\n');
			ligne := reader.readLine();
		}
		reader.close();
		return builder.string;
	}


	shared actual void handle(HttpExchange httpExchange) {
		try {
			String payload = getPayload(httpExchange.requestBody);
			logRequest(httpExchange, payload);
			String? query = httpExchange.requestURI.rawQuery;
			Response? response = handleQuery(query);
			if (is Response response) {
				sendResponse(httpExchange, response.response, response.status, response.contentType);
				return;
			}
			Response? responsePath = handlePath(httpExchange.requestURI.path, payload);
			if (is Response responsePath) {
				sendResponse(httpExchange, responsePath.response, responsePath.status, responsePath.contentType);
				return;
			} else {
				sendResponse(httpExchange, "I can't response to your query", httpBadRequest);
			}
		} catch (Exception exception) {
			exception.printStackTrace();
			sendResponse(httpExchange, "I can't response to your query", httpBadRequest);
		}
	}

	void sendResponse(HttpExchange httpExchange, String response, Integer status = httpOk, String contentType = "text/html;charset=UTF-8") {
 		Headers headers = httpExchange.responseHeaders;
        headers.set("Content-Type", contentType);
        httpExchange.sendResponseHeaders(status, response.size);
        OutputStream os = httpExchange.responseBody;
        os.write(javaString(response).getBytes("UTF-8"));
        os.close();	
		logResponse(response, status);
	}

	void logRequest(HttpExchange exchange, String payload) {
		print("" dateFormat.format(Date()) ":" exchange.requestMethod ":" exchange.requestURI.string "");
		print(payload);
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


