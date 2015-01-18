package com.reader.xls;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Scanner;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Set;
import java.util.regex.Pattern;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;

public class XLSReader {
	private final static int SIZE = 4096;
	//private final static String FILEFOLDER = "/Users/Victor/Desktop/";
	//private final static String FILEFOLDER = "C:/Users/alvin.soh.2011/Desktop/";
	private final static String FILEFOLDER = "C:/Users/rubberduck/Desktop/";
	private final static String FILENAME = "smuconfessions";
	private final static String FILETYPE = ".txt";
	
	//private final static String FILEFOLDER2 = "/Users/Victor/Desktop/";
	//private final static String FILEFOLDER2 = "C:/Users/alvin.soh.2011/Desktop/";
	private final static String FILEFOLDER2 = "C:/Users/rubberduck/Desktop/";
	private final static String FILENAME2 = "stopwords";
	private final static String FILETYPE2 = ".txt";
	
	public static ArrayList<String> confessions = null;
	public static ArrayList<String> ignoreWords = null;

	
	public static void extractAll(){
		confessions = new ArrayList<String>();
		ignoreWords = new ArrayList<String>();
		long duration = 0;
		int fileCount = 0;
		try {
		
			//List data = new ArrayList();
			FileInputStream f;
			
			f = new FileInputStream(FILEFOLDER + FILENAME + FILETYPE);
			
			FileChannel ch = f.getChannel( );
			
			StringBuilder superStringBuilder = new StringBuilder();

			MappedByteBuffer mb = null;
			try {
				mb = ch.map(FileChannel.MapMode.READ_ONLY, 0L, ch.size( ) );
			} catch (IOException e) {
				e.printStackTrace();
			}
			int nGet;
			while(mb.hasRemaining()){
				byte[] barray = new byte[SIZE];
				nGet = Math.min( mb.remaining(), SIZE);
			    mb.get(barray, 0, nGet);
			    superStringBuilder.append(new String(barray));
			}
			
			//System.out.println("IT IS " + superStringBuilder.length() + " CHARS LONG!");
			//System.out.println(superStringBuilder.toString());
			
			Pattern p = Pattern.compile("(\\r\\n?|\\n)");
			//Pattern p = Pattern.compile("\\r?\\n");
			String[] allRows = p.split(superStringBuilder.toString());
			//System.out.println("There are " + allRows.length + " rows!");			
			for (String token : allRows) {
				String[] confession = token.trim().split("\t");
				if (confession.length > 1) {
					String message = confession[1];
					message = message.replaceAll(",", ""); // removed all commas
					message = message.replaceAll("\\.", ""); // removed all fullstops
					message = message.replaceAll("-", " "); // removed all dashes
					message = message.replaceAll("\\?", " "); // removed all question marks
					message = message.replaceAll("\"", " "); // removed all double inverted commas
					message = message.replaceAll(":", ""); // removed colon
					message = message.replaceAll("\\(", " "); // removed brackets
					message = message.replaceAll("\\)", " ");
					message = message.replaceAll("#", " "); // removed hash
					message = message.replaceAll(";", " ");
					message = message.replaceAll("!", " ");
					message = message.toLowerCase();
					confession[1] = message;
					
					confessions.add(confession[0] + "\t" + confession[1] + "\t" + confession[2] + "\t" + confession[3] + "\t" + confession[4]);
					//data.add(token.trim().split("\t"));
				}
			}
			//System.out.println("confessions size: " + confessions.size());
			superStringBuilder = null;
			//System.out.println("File is loaded!");
			f.close();
			
			f = new FileInputStream(FILEFOLDER2 + FILENAME2 + FILETYPE2);
			
			ch = f.getChannel( );
			
			superStringBuilder = new StringBuilder();

			mb = null;
			try {
				mb = ch.map(FileChannel.MapMode.READ_ONLY, 0L, ch.size( ) );
			} catch (IOException e) {
				e.printStackTrace();
			}
			//int nGet;
			while(mb.hasRemaining()){
				byte[] barray = new byte[SIZE];
				nGet = Math.min( mb.remaining(), SIZE);
			    mb.get(barray, 0, nGet);
			    superStringBuilder.append(new String(barray));
			}
			
			//System.out.println("IT IS " + superStringBuilder.length() + " CHARS LONG!");
			//System.out.println(superStringBuilder.toString());
			
			p = Pattern.compile(", ");
			String[] allIgnoredWords = p.split(superStringBuilder.toString());
			//System.out.println("There are " + allIgnoredWords.length + " ignored words!");
						
			//data.add(token.trim().split("\t"));
			for (String s : allIgnoredWords) {
				//System.out.println(s);
				//System.out.println("stopword: " + s);
				ignoreWords.add(s);
			}
			
			superStringBuilder = null;
			//System.out.println("Files are loaded!");
			f.close();
			
			ignoreWords.add("");
			ignoreWords.add("==========");
			ignoreWords.add("http//confessingin/smusg/confess");
		
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}
	
	/*
	public static void extractAll2() {  // extract all confessions to ArrayList confessions
		Scanner sc = null;
		Scanner sc1 = null;
		confessions = new ArrayList<String>();
		try {
			sc = new Scanner(new File("/Users/Victor/Desktop/smuconfessions.txt"));
			//sc = new Scanner(new File("C:/Users/rubberduck/Desktop/smuconfessions.txt"));
			
			while (sc.hasNext()) {
				String line = sc.nextLine();
				confessions.add(line);
			}
		} catch (FileNotFoundException e) {
			System.out.println("File not found in extractAll in XLSReader");
		}
		System.out.println("XLSReader: " + confessions.size() + " rows added!");
		
		try {
			sc1 = new Scanner(new File("/Users/Victor/Desktop/stopwords.txt"));
			//sc1 = new Scanner(new File("C:/Users/rubberduck/Desktop/stopwords.txt"));
			
			while (sc1.hasNext()) {
				String line = sc1.nextLine();
				String[] lineArr = line.split(", ");
				for (String s : lineArr) {
					//System.out.println(s);
					ignoreWords.add(s);
				}
			}
		} catch (FileNotFoundException e) {
			System.out.println("File stopwords.txt not found in extractAll in XLSReader");
		}
		
		ignoreWords.add("");
		ignoreWords.add("==========");
		ignoreWords.add("http//confessingin/smusg/confess");
		for (String s : ignoreWords) {
			System.out.println("ignoreWord: " + s);
		}
		// System.out.println("Total confessions: " + confessions.size());
	}
	*/

	public static HashMap<String, Integer> countAllConfessions() {  // get count for all words
		HashMap<String, Integer> words = new HashMap<String, Integer>();
		
		for (String confession : confessions) {
			String[] confessionArr = confession.split("\t");
			
			String message = confessionArr[1];
			int startIndex = message.indexOf("========== ");
			int endIndex = message.lastIndexOf("==========");
			if (startIndex > -1 && endIndex > -1) {
				message = message.substring(startIndex+11, endIndex-1);
			}
			
			String[] messageArr = message.split(" ");  // individual words in confessions
			for (String s : messageArr) {
				if (!ignoreWords.contains(s) && words.get(s) == null) {
					words.put(s, 1);
				} else if (!ignoreWords.contains(s)) {
					int count = words.get(s);
					words.put(s, ++count);
				}
			}
		}
		
		return words;
	}
	
	public static HashMap<String, Integer> countSelectedConfessions(ArrayList<String> selectedConfessions) {  // get count for all words in selected Confessions
		HashMap<String, Integer> words = new HashMap<String, Integer>();
		//System.out.println("Selected confessions inserted size: " + selectedConfessions.size());
		
		for (String confession : selectedConfessions) {
			String[] confessionArr = confession.split("\t");
			
			String message = confessionArr[1];
			int startIndex = message.indexOf("========== ");
			int endIndex = message.lastIndexOf("==========");
			if (startIndex > -1 && endIndex > -1) {
				message = message.substring(startIndex+11, endIndex-1);
			}
			
			String[] messageArr = message.split(" ");  // individual words in confessions
			//System.out.println("message: " + message);
			for (String s : messageArr) {
				if (!ignoreWords.contains(s) && words.get(s) == null && !isNumeric(s)) {
					words.put(s, 1);
				} else if (!ignoreWords.contains(s) && !isNumeric(s)) {
					int count = words.get(s);
					words.put(s, ++count);
				}
			}
		}
		
		return words;
	}
	
	public static ArrayList<String> sortMap(final HashMap<String, Integer> confessions) {
		Set<String> keys = confessions.keySet();
		ArrayList<String> keyArr = new ArrayList<String>();
		for (String key : keys) {
			keyArr.add(key);
		}
		
		Collections.sort(keyArr, new Comparator<String>() {
			public int compare(String a, String b) {
				int count1 = confessions.get(a);
				int count2 = confessions.get(b);
				return (int) (count2-count1);
			}
		});
		
		/*for (int i = 0; i < 60; i++) {  // These are the top 60 words
			String s = keyArr.get(i);
			System.out.println(s);
		}*/
		return keyArr;
	}
	
	public static HashMap<String, Integer> getLikes(ArrayList<String> selectedConfessions) {
		HashMap<String, Integer> likes = new HashMap<String, Integer>();
		//System.out.println("Selected confessions inserted size: " + selectedConfessions.size());
		
		for (String confession : selectedConfessions) {
			String[] confessionArr = confession.split("\t");
			String strLikes = confessionArr[3];
			int like = Integer.parseInt(strLikes);
			
			String message = confessionArr[1];
			int startIndex = message.indexOf("========== ");
			int endIndex = message.lastIndexOf("==========");
			if (startIndex > -1 && endIndex > -1) {
				message = message.substring(startIndex+11, endIndex-1);
			}
			
			String[] messageArr = message.split(" ");  // individual words in confessions
			//System.out.println("message: " + message);
			for (String s : messageArr) {
				if (!ignoreWords.contains(s) && likes.get(s) == null && !isNumeric(s)) {
					likes.put(s, like);
				} else if (!ignoreWords.contains(s) && !isNumeric(s)) {
					int count = likes.get(s);
					likes.put(s, count + like);
				}
			}
		}
		
		return likes;
	}
	
	public static boolean isNumeric(String str) {
		try {  
		    double d = Double.parseDouble(str);  
		} catch(NumberFormatException nfe) {  
		    return false;  
		}  
		return true;
	}
}
