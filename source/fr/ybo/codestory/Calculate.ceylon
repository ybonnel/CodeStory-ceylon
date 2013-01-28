import java.util { Locale { france = \iFRANCE } }
import java.text { NumberFormat, DecimalFormat, DecimalFormatSymbols }
import groovy.lang { GroovyShell }
import java.math { BigDecimal }
import java.lang { IllegalArgumentException, JavaInteger=Integer }


shared class Calculate() {

	NumberFormat format = DecimalFormat("#0.#", DecimalFormatSymbols(france));
	format.maximumFractionDigits := 500;
	GroovyShell shell = GroovyShell();
	
	shared String calculate(String query) {
		Object objet = shell.evaluate("return " + query.replace(' ', '+').replace(',', '.'));
		
		if (is JavaInteger objet) {
			return objet.string;
		} else if (is BigDecimal objet) {
			return format.format(objet);
		} else {
			throw IllegalArgumentException("Unkown type");
		}
	}
	
}




