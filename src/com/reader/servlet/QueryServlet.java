package com.reader.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONArray;
import org.json.simple.JSONValue;

import com.reader.xls.XLSReader;
import com.search.lucene.LuceneSearch;
import com.search.lucene.Multiplier;

/**
 * Servlet implementation class QueryServlet
 */
@WebServlet("/QueryServlet")
public class QueryServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public QueryServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//System.out.println("erm!");
		
		String query = request.getParameter("query");
		
		if (XLSReader.confessions == null){
			XLSReader.extractAll();
		} else {
			//System.out.println("XLSReader.confessions is not null");
		}
		
		ArrayList<String> allConfessions = XLSReader.confessions;
		LuceneSearch ls = new LuceneSearch(allConfessions);
		
		ArrayList<String> foundConfessions = ls.search(query);
				
		
		XLSReader.countAllConfessions();
		HashMap<String, Integer> confessions = null;
		HashMap<String, Integer> likesHash = null;
		ArrayList<String> selectedConfessions = new ArrayList<String>(XLSReader.confessions);
		
		if (query != null && !query.equals("")) {
			ls = new LuceneSearch(XLSReader.confessions);
			selectedConfessions = ls.search(query);
			//session.removeAttribute("query");
			
			confessions = XLSReader.countSelectedConfessions(selectedConfessions);
		} else {
			confessions = XLSReader.countAllConfessions();
		}
		likesHash = XLSReader.getLikes(selectedConfessions);
		
		ArrayList<String> sortedConfessions = XLSReader.sortMap(confessions);  // These are the words in descending order || count can be retrieved from hashmap
		if (sortedConfessions.size() == 0) {
			sortedConfessions.add("No result");
			confessions.put("No result", 1);
		}
		//String wordList = "\"" + sortedConfessions.get(0) + "\"";
		String wordList = sortedConfessions.get(0);
		
		// LEVEL 1 JSON
		String mapKey = "\"" + sortedConfessions.get(0) + "\"";
		int mapValue = confessions.get(sortedConfessions.get(0));
		
		JSONArray jsonWordCloudMap = new JSONArray();
		
		Map objMap = new LinkedHashMap();
		objMap.put("mapKey", mapKey);
		objMap.put("mapValue", mapValue);
		
		jsonWordCloudMap.add(objMap);
		
		
		
		int max = 60;
		if (sortedConfessions.size() < 60) {
			max = sortedConfessions.size();
		}
		for (int i = 1; i < max; i++) {
			wordList += "," + sortedConfessions.get(i);
			
			mapKey = "\"" + sortedConfessions.get(i) + "\"";
			mapValue = confessions.get(sortedConfessions.get(i));

			objMap = new LinkedHashMap();
			objMap.put("mapKey", mapKey);
			objMap.put("mapValue", mapValue);
			jsonWordCloudMap.add(objMap);
		}
	
		JSONArray jsonWordCloudArr = new JSONArray();
		//System.out.println("Selected Confessions size: " + selectedConfessions.size());
		for (int i = 0; i < selectedConfessions.size(); i++) {
			String s = selectedConfessions.get(i);
			s = s.replaceAll("'", "");
			
			objMap = new LinkedHashMap();
			objMap.put("arrKey", i);
			objMap.put("arrValue", s);
			jsonWordCloudArr.add(objMap);
		}
		
		JSONArray jsonWordCloudHash = new JSONArray();
		for (int i = 0; i < max; i++) {
			String s = sortedConfessions.get(i);
			objMap = new LinkedHashMap();
			objMap.put("hashKey", s);
			objMap.put("hashValue", confessions.get(s));
			jsonWordCloudHash.add(objMap);
		}
		
		
		JSONArray jsonWordCloudLikes = new JSONArray();
		for (int i = 0; i < max; i++) {
			String s = sortedConfessions.get(i);
			objMap = new LinkedHashMap();
			objMap.put("likesKey", s);
			objMap.put("likesValue", likesHash.get(s));
			jsonWordCloudLikes.add(objMap);
		}

		JSONArray jsonWordCloudWordList = new JSONArray();
		objMap = new LinkedHashMap();
		objMap.put("wordList", wordList);
		jsonWordCloudWordList.add(objMap);
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		// LINE GRAPH THINGY
		
		LinkedHashMap<String,String> postsVsDateMap = new LinkedHashMap<String,String>(); 
		
		Calendar currentCheckingDate = Calendar.getInstance();
		currentCheckingDate.set(2013, Calendar.JANUARY, 1); // START FROM JAN 1st 2013
		
		//Calendar startDate = Calendar.getInstance();
		String currentKey = "";
		int currentValue = 0;
		
		SimpleDateFormat parserSDF = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		
		int counter = 0;
		String lastCheckedDate = null;
		// Fill up the rest
		while (currentCheckingDate.get(Calendar.MONTH) != 11){
			currentCheckingDate.set(Calendar.HOUR_OF_DAY, 0);
			currentCheckingDate.set(Calendar.MINUTE, 0);
			currentCheckingDate.set(Calendar.SECOND, 0);
			currentCheckingDate.set(Calendar.MILLISECOND, 0);
			lastCheckedDate = parserSDF.format(currentCheckingDate.getTime());
			//System.out.println(lastCheckedDate);
			postsVsDateMap.put(lastCheckedDate, Integer.toString(currentValue));
			
			//currentCheckingDate.add(Calendar.DATE, 1); // Increment 1 day
			currentCheckingDate.add(Calendar.MONTH, 1); // Increment 1 month
			
		} // end of while loop
		
		JSONArray jsonDataTable = new JSONArray();
		Collections.sort(foundConfessions);
		//System.out.println("There are " + foundConfessions.size() + " confessions ready for filtering.");
		for (int i = counter; i < foundConfessions.size(); i++){
			String eachConfession = foundConfessions.get(i);
			String[] parts = eachConfession.split("\t");
			/*
			Map obj = new LinkedHashMap();
	        obj.put("post_id", parts[0]);
	        obj.put("message", parts[1]);
	        obj.put("comment_num", parts[2]);
	        obj.put("likes", parts[3]);
	        obj.put("datetime", parts[4]);
	        */
			JSONArray miniArray = new JSONArray();
			String url = "http://www.facebook.com/";
			String url1 = "<a href='http://www.facebook.com/";
			//"<a href='http://www.facebook.com/" + "123456'>" + "123456" + "</a>"
			String url2 = "'>";
			String url3 = "</a>";
			
			String urlx = "<a href='http://www.facebook.com/SMUConfessionsPage/posts/";
			
			miniArray.add(parts[4]);
			miniArray.add(parts[1]);
			miniArray.add(parts[3]);
			miniArray.add(parts[2]);
			
			parts[0].substring(parts[0].indexOf("_"));
			//miniArray.add(url1+parts[0]+url2+parts[0]+url3);
			miniArray.add(urlx+parts[0].substring(parts[0].indexOf("_")+1)+url2+parts[0]+url3);
			jsonDataTable.add(miniArray);
	        
			//System.out.println(parts[0] + "\t" + parts[1] + "\t" + parts[2] + "\t" + parts[3] + "\t" + parts[4]);
			
			Date aDate = null;
			//System.out.println(parts[4]);
			try {
				aDate = parserSDF.parse(parts[4]);
			} catch (ParseException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			
			if (i != 0){
				//String previousConfession = foundConfessions.get(i-1);
				//String[] previousParts = eachConfession.split("\t");
				
				Calendar cal1 = Calendar.getInstance();
				//Calendar cal2 = Calendar.getInstance();
				
				cal1.setTime(aDate);
				//cal2.setTime(parserSDF.parse(previousParts[4]));
				
				//boolean sameDay = cal1.get(Calendar.YEAR) == currentCheckingDate.get(Calendar.YEAR) &&
				//                  cal1.get(Calendar.DAY_OF_YEAR) == currentCheckingDate.get(Calendar.DAY_OF_YEAR);
				
				boolean sameMonth = cal1.get(Calendar.YEAR) == currentCheckingDate.get(Calendar.YEAR) &&
		                  cal1.get(Calendar.MONTH) == currentCheckingDate.get(Calendar.MONTH);
				//System.out.println("confession month: " + cal1.get(Calendar.MONTH));
				//System.out.println("current month: " + currentCheckingDate.get(Calendar.MONTH));
				if(sameMonth) {
					currentValue += 1;
				} else {
					lastCheckedDate = parserSDF.format(currentCheckingDate.getTime());
					postsVsDateMap.put(lastCheckedDate, Integer.toString(currentValue));
					
					currentValue = 1;
					currentCheckingDate.setTime(aDate);
					currentCheckingDate.set(currentCheckingDate.get(Calendar.YEAR),currentCheckingDate.get(Calendar.MONTH),1);
					currentCheckingDate.set(Calendar.HOUR_OF_DAY, 0);
					currentCheckingDate.set(Calendar.MINUTE, 0);
					currentCheckingDate.set(Calendar.SECOND, 0);
					currentCheckingDate.set(Calendar.MILLISECOND, 0);
				}
				
			} else {
				currentCheckingDate.setTime(aDate);
				currentCheckingDate.set(currentCheckingDate.get(Calendar.YEAR),currentCheckingDate.get(Calendar.MONTH),1);
				currentCheckingDate.set(Calendar.HOUR_OF_DAY, 0);
				currentCheckingDate.set(Calendar.MINUTE, 0);
				currentCheckingDate.set(Calendar.SECOND, 0);
				currentCheckingDate.set(Calendar.MILLISECOND, 0);
				currentValue = 1;
			}
			
			if (i == (foundConfessions.size()-1)) {
				lastCheckedDate = parserSDF.format(currentCheckingDate.getTime());
				postsVsDateMap.put(lastCheckedDate, Integer.toString(currentValue));
			}
			
		} // end of FOR loop
		
		JSONArray jsonConfessions = new JSONArray();
		Iterator it = postsVsDateMap.entrySet().iterator();
		ArrayList<String> unsortedKeys = new ArrayList<String>();
	    while (it.hasNext()) {
	        Map.Entry pairs = (Map.Entry)it.next();
	        unsortedKeys.add((String)pairs.getKey());
	        //System.out.println(pairs.getKey());
	        //it.remove(); // avoids a ConcurrentModificationException
	        //System.out.println(postsVsDateMap.size());
	    }
	    
	    Collections.sort(unsortedKeys);
	    
	    for (String key: unsortedKeys){
	    	Map obj = new LinkedHashMap();
	        obj.put("datetime", key);
	        obj.put("numberofposts", postsVsDateMap.get(key));
	        //System.out.println(key + " = " + postsVsDateMap.get(key));
	        jsonConfessions.add(obj);
	    }
	    
	    Map jsonEverything = new LinkedHashMap();
	    Map jsonDataTableOuterLayer = new LinkedHashMap();
	    jsonDataTableOuterLayer.put("aaData", jsonDataTable);
	    
	    jsonEverything.put("jsonForLineGraph", jsonConfessions);
	    jsonEverything.put("jsonForDataTable", jsonDataTableOuterLayer);
	    jsonEverything.put("jsonForWordCloudMap", jsonWordCloudMap);
	    jsonEverything.put("jsonForWordCloudArr", jsonWordCloudArr);
	    jsonEverything.put("jsonForWordCloudHash", jsonWordCloudHash);
	    jsonEverything.put("jsonForWordCloudLikes", jsonWordCloudLikes);
	    jsonEverything.put("jsonForWordCloudWordList", wordList);
	    
	    double multiplier = Multiplier.calculateMultiplier(sortedConfessions, confessions);
	    jsonEverything.put("jsonForWordCloudMultiplier", multiplier);
	    //jsonEverything.add(jsonForWordCloud);
	    //jsonEverything.add(jsonForLineGraph);
	    
		//String jsonText = JSONArray.toJSONString(jsonConfessions);
	    String jsonText = JSONValue.toJSONString(jsonEverything);
		response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.println(jsonText);
        //System.out.println(jsonText);
	}

}
