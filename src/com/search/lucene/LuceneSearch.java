package com.search.lucene;

import java.io.IOException;
import java.util.ArrayList;

import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopScoreDocCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.RAMDirectory;
import org.apache.lucene.util.Version;

public class LuceneSearch {
	private StandardAnalyzer analyzer;
	private Directory index;
	
	public LuceneSearch(ArrayList<String> confessions) {
	    // 0. Specify the analyzer for tokenizing text.
	    //    The same analyzer should be used for indexing and searching

	    analyzer = new StandardAnalyzer(Version.LUCENE_40);
	
	    // 1. create the index
	    index = new RAMDirectory();
	
	    IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_40, analyzer);
	    
	    try {
		    IndexWriter w = new IndexWriter(index, config);
		    for (String s : confessions) {
		    	String[] confessionArr = s.split("\t");
		    	String post_id = confessionArr[0];
		    	String message = confessionArr[1];
		    	String comment_num = confessionArr[2];
		    	String likes = confessionArr[3];
		    	String time = confessionArr[4];
		    	
		    	addDoc(w, post_id, message, comment_num, likes, time);
		    }
		    w.close();
	    } catch (IOException e) {
	    	System.out.println("Error in constructor in LuceneSearch");
	    }
	
	}
	
	public ArrayList<String> search(String strQuery) {
		String[] orgQuery = strQuery.split(" ");
		int j = 0;
	    for( int i=0;  i<orgQuery.length;  i++ )
	    {
	        orgQuery[j++] = orgQuery[i];
	    }
	    String [] query = new String[j];
	    System.arraycopy( orgQuery, 0, query, 0, j );
	    
		ArrayList<String> confessions = new ArrayList<String>();
		
		IndexReader reader = null;
	    // 2. query
	    String querystr = "\"";
	    for (int i = 0; i < query.length; i++) {
	    	String q = query[i];
	    	querystr += q;
	    	if (i != query.length - 1) {
	    		querystr += " ";
	    	}
	    }
	    querystr += "\"~10";
	    try {
		    Query q1 = new QueryParser(Version.LUCENE_40, "message", analyzer).parse(querystr);
		   // System.out.println("after query is parsed");
		    
		    // 3. search
		    int hitsPerPage = 14000;
		    reader = DirectoryReader.open(index);
		    IndexSearcher searcher = new IndexSearcher(reader);
		    TopScoreDocCollector collector = TopScoreDocCollector.create(hitsPerPage, true);
		    
		    try {
		    	//System.out.println("Before booleanQUery");
				BooleanQuery booleanQuery = new BooleanQuery();
				
				booleanQuery.add(q1, BooleanClause.Occur.SHOULD);
				
				searcher.search(booleanQuery, collector);
			} catch (IOException e) {
				e.printStackTrace();
			}
		    
		    ScoreDoc[] hits = collector.topDocs().scoreDocs;
		    
		    // 4. display results
		    //System.out.println("Found " + hits.length + " hits.");
		    for(int i=0;i<hits.length;++i) {
		      int docId = hits[i].doc;
		      Document d = searcher.doc(docId);
		      //System.out.println(d.get("message"));
		      confessions.add(d.get("post_id") + "\t" + d.get("message") + "\t" + d.get("comment_num") + "\t" + d.get("likes") + "\t" + d.get("time"));
		    }
		    
		    reader.close();
	    } catch (ParseException e) {
	    	System.out.println("Error in search in LuceneSearch");
	    } catch (IOException e) {
	    	System.out.println("Error with DirectoryReader or closing reader in search in LuceneSearch");
	    }
	
	    // reader can only be closed when there
	    // is no need to access the documents any more.
	    /* for (String s : confessions) {
	    	System.out.println(s);
	    }*/
	    //System.out.println("confessions size: " + confessions.size());
	    return confessions;
	}
	
  private static void addDoc(IndexWriter w, String post_id, String message, String comment_num, String likes, String time) throws IOException {
    Document doc = new Document();
    doc.add(new TextField("post_id", post_id, Field.Store.YES));
    doc.add(new TextField("message", message, Field.Store.YES));
    doc.add(new TextField("comment_num", comment_num, Field.Store.YES));
    doc.add(new TextField("likes", likes, Field.Store.YES));
    doc.add(new TextField("time", time, Field.Store.YES));

    // use a string field for isbn because we don't want it tokenized
    //doc.add(new StringField("isbn", isbn, Field.Store.YES));
    w.addDocument(doc);
  }
}