import com.sun.net.httpserver { HttpServer { createHttpServer=create } }
import java.net { InetSocketAddress }
import fr.ybo.codestory { Handler }
import org.junit { Assert { assertEquals } }
import ceylon.net.uri { parseURI, URI }
import ceylon.net.http { Request, Response }
import java.lang { AssertionError }
import com.meterware.httpunit { WebConversation }

variable HttpServer? server := null; 

void startServer() {
	server := createHttpServer(InetSocketAddress(9090), 0);
	if (is HttpServer httpServer = server) {
		httpServer.createContext("/", Handler());
		httpServer.executor := null;
	    // Start to accept incoming connections
	    httpServer.start();
	}

}

void stopServer() {
	if (is HttpServer httpServer = server) {
		httpServer.stop(0);
	}
}

class WebServerTest() {
	
	value url = "http://localhost:9090/?q=";
	
	value expectedResponses = {
		url + "Quelle est ton adresse email" -> "ybonnel@gmail.com",
		url + "Es tu abonne a la mailing list(OUI/NON)" -> "OUI",
		url + "Es tu heureux de participer(OUI/NON)" -> "OUI",
		url + "Es tu pret a recevoir une enonce au format markdown par http post(OUI/NON)" -> "OUI",
		url + "Est ce que tu reponds toujours oui(OUI/NON)" -> "NON"	}; 

	shared void should_answer_to_expectedResponses() {
		for (expectedResponse in expectedResponses) {
			URI uri = parseURI(expectedResponse.key);
		    Request request = uri.get();
		    Response response = request.execute();
			assertEquals(200, response.status);
		    assertEquals(expectedResponse.item, response.contents);
		}
	}
}

void runATest(void test()) {
	try {
		test();
	} catch (AssertionError exception) {
		print("ERROR : " + exception.message);
	}
} 

void run() {
	startServer();
	WebServerTest test = WebServerTest();
	runATest(test.should_answer_to_expectedResponses);
	stopServer();
}



