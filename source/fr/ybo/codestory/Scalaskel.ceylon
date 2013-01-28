import ceylon.collection { LinkedList }



shared class Coin(Integer coinValue) {
	shared Integer valeur = coinValue;
	shared Boolean canPay(Integer centsToPay) {
		return centsToPay >= valeur;
	}
	
}

Coin[] possibleCoins = {
	Coin(1),
	Coin(7),
	Coin(11),
	Coin(21)
};

shared class Change(Change? currentChange = null) {
	shared variable Integer foo := currentChange?.foo else 0;
	shared variable Integer bar := currentChange?.bar else 0;
	shared variable Integer qix := currentChange?.qix else 0;
	shared variable Integer baz := currentChange?.baz else 0;
	
	shared void pay(Integer coin) {
		if (coin == 1) {
			foo++;
		}
		if (coin == 7) {
			bar++;
		}
		if (coin == 11) {
			qix++;
		}
		if (coin == 21) {
			baz++;
		}
		
	}
	
	shared String toJson() {
		StringBuilder builder = StringBuilder();
		
		builder.append('{');
		if (foo != 0) {
 			builder.append("\"foo\":" + foo.string);
 		}
		if (bar != 0) {
 			if (builder.size > 1) {
 				builder.append(',');
 			}
 			builder.append("\"bar\":" + bar.string);
 		}
		if (qix != 0) {
 			if (builder.size > 1) {
 				builder.append(',');
 			}
 			builder.append("\"qix\":" + qix.string);
 		}
		if (baz != 0) {
 			if (builder.size > 1) {
 				builder.append(',');
 			}
 			builder.append("\"baz\":" + baz.string);
 		}
 		builder.append('}');
		return builder.string;
	}
}


shared String toJson(LinkedList<Change> changes) {
	StringBuilder builder = StringBuilder();
	builder.append('[');
	for (Change change in changes) {
		if (builder.size > 1) {
			builder.append(',');
		}
		builder.append(change.toJson());
	}
	builder.append(']');
	return builder.string;
}


shared class Scalaskel() {
	
	shared LinkedList<Change> calculate(Integer cents) {
		return completeChanges(cents, Change(), Coin(1));
	}
	
	
    LinkedList<Change> completeChanges(Integer cents, Change currentChange, Coin lastCoin) {
        // Stop condition of recursivity
        value changes = LinkedList<Change>();
        if (cents == 0) {   
            changes.add(currentChange);
            return changes;
        }
        
        for (Coin coin in possibleCoins) {
            if (lastCoin.valeur <= coin.valeur && coin.canPay(cents)) {
                
	            Change change = Change(currentChange);
	            change.pay(coin.valeur);
	            for (Change newChange in completeChanges(cents - coin.valeur, change, coin)) {
	                changes.add(newChange);
	            }
        	}
        }
        return changes;
    }
	
	
}