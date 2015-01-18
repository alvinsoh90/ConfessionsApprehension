package com.search.lucene;

import java.util.ArrayList;
import java.util.HashMap;

public class Multiplier {
	public static double calculateMultiplier(ArrayList<String> arr, HashMap<String, Integer> hash) {
		double multiplier = 0.0;
		int max = 60;
		
		if (arr.size() < 60) {
			max = arr.size();
		}
		for (int i = 0; i < max; i++) {
			String s = arr.get(i);
			multiplier += hash.get(s);
		}
		
		multiplier /= max;
		multiplier = 24/multiplier;
		
		if (multiplier < 0.03) {
			multiplier = 0.03;
		} else if (multiplier > 16) {
			multiplier = 16;
		}
		//System.out.println("Multiplier: " + multiplier);
		return multiplier;
	}
}
