/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.rest
{
	import com.adobe.serializers.json.JSONDecoder;
	
	import mx.collections.ArrayCollection;
	
	public class JSONClient extends RestClientBase
	{
		public function JSONClient(rootURL:String = "")
		{
			super(rootURL);
			addResultProcessor(parseJSON);
		}
		
		protected function parseJSON(data:*):Object // NO PMD
		{
			// Hack:
			if (data == '[]')
				return new ArrayCollection();
			if (data == '')
				return null;
			return new JSONDecoder().decode(String(data));
		}
	}
}