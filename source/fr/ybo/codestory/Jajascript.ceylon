import ceylon.collection { LinkedList }
import ceylon.language { Integer { compareInt = compare } }
import java.util { BitSet }
import java.lang { IllegalAccessException }
import java.util.regex { Pattern { compile }, Matcher }
import ceylon.interop.java { javaString }


shared class Flight(name, startTime, duration, price) {
	shared String name;
	shared Integer startTime;
	shared Integer duration;
	shared Integer price;
	
	shared actual String string = "name:"name",startTime:"startTime",duration:"duration",price:"price"";}

shared class Solution(price, endTime, BitSet? acceptedFlightsFrom, Integer flightIndex) {
	shared Integer endTime;
	shared Integer price;
	shared BitSet acceptedFlights = BitSet();
	if (is BitSet acceptedFlightsFrom) {
		acceptedFlights.or(acceptedFlightsFrom);
	}
	acceptedFlights.set(flightIndex);
}

Comparison? compareFlight(Flight x, Flight y) {
	Integer a = x.startTime;
	Integer b = x.startTime;
	return a.compare(b);}

shared class JajascriptResponse(Integer gain, LinkedList<String> path) {
	
	shared String toJson() {
		StringBuilder builder = StringBuilder();
		builder.append("{\"gain\":");
		builder.append(gain.string);
		builder.append(",\"path\":[");
		Integer firstLenght = builder.size;
		for (String onePath in path) {
			if (builder.size > firstLenght) {
				builder.append(',');
			}
			builder.append('"');
			builder.append(onePath);
			builder.append('"');
		}
		builder.append("]}");
		return builder.string;
	}
	}

shared String getJajascriptResponse(String payload) {
	
	LinkedList<Flight> flights = LinkedList<Flight>();
	Pattern patternArray = compile("\\[(.*)\\].*");
    Pattern patternCommande = compile("\\{ ?\"VOL\" ?\\: ?\"([\\w\\-]+)\" ?, ?\"DEPART\" ?\\: ?(\\d+) ?, ?\"DUREE\" ?\\: ?(\\d+) ?, ?\"PRIX\" ?\\: ?(\\d+) ?\\}");
    Matcher matcher = patternArray.matcher(javaString(payload));
     
     if (matcher.matches()) {
         String commandesPayLoad = matcher.group(1);
         Matcher matcherCommande = patternCommande.matcher(javaString(commandesPayLoad));
         
         while (matcherCommande.find()) {
             Flight flight = Flight(
             	matcherCommande.group(1),
             	parseInteger(matcherCommande.group(2)) else 0,
             	parseInteger(matcherCommande.group(3)) else 0,
             	parseInteger(matcherCommande.group(4)) else 0
             );
             flights.add(flight);
         }
     }
    
    
	
	JajascriptResponse response = Jajascript(flights).optimize();
	
	return response.toJson();}

shared class Jajascript(LinkedList<Flight> flights) {
	flights.sort((Flight x, Flight y) compareFlight(x, y));
	
	value solutions = LinkedList<Solution>();
	
	shared JajascriptResponse optimize() {
		print("NbFlights : "flights.size"");
		
		variable Integer index := 0;
		for (Flight flight in flights) {
			variable Solution? bestSolution := null;
			variable Integer bestPrice := 0;
			
			for (Solution solution in solutions) {
				if (flight.startTime >= solution.endTime
					&& solution.price > bestPrice) {
					bestSolution := solution;
					bestPrice := solution.price;
				}
			}
			
			Integer newPrice = (bestSolution?.price else 0) + flight.price;
			
			Solution newSolution = Solution(newPrice, flight.startTime + flight.duration, bestSolution?.acceptedFlights, index);
			solutions.add(newSolution);
			
			index++;
		}
		
		variable Solution? bestSolution := null;
		for (Solution solution in solutions) {
			if (solution.price > (bestSolution?.price else 0)) {
				bestSolution := solution;
			}
		}
		
		if (is Solution bestSolutionFound = bestSolution) {
			
			value path = LinkedList<String>();
			
			for (Integer indexFlight in 0..(flights.size-1)) {
				if (bestSolutionFound.acceptedFlights.get(indexFlight)) {
					path.add(flights.item(indexFlight)?.name else "");
				}
			}
			
			return JajascriptResponse(bestSolutionFound.price, path);
		}
		
		throw IllegalAccessException("No solution found");
	}
	
	

}
