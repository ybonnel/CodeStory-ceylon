import com.sun.net.httpserver { HttpServer { createHttpServer=create } }
import java.net { InetSocketAddress }
import fr.ybo.codestory { Handler }
import org.junit { Assert { assertEquals } }
import ceylon.net.uri { parseURI, URI }
import ceylon.net.http { Request, Response }
import java.lang { AssertionError }

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

	shared void should_answer_to_whatsyourmail() {
		URI uri = parseURI("http://localhost:9090/?q=Quelle est ton adresse email");
	     Request request = uri.get();
	     Response response = request.execute();
		 assertEquals(200, response.status);
	     assertEquals("ybonnel@gmail.com", response.contents);
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
	runATest(test.should_answer_to_whatsyourmail);
	stopServer();
}



