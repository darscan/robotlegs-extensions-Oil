//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.oil.rest
{
	import com.adobe.serializers.json.JSONDecoder;
	import com.adobe.serializers.json.JSONEncoder;
	import flash.utils.describeType;
	import mx.collections.ArrayCollection;

	public class JSONClient extends RestClientBase
	{

		/*============================================================================*/
		/* Protected Properties                                                       */
		/*============================================================================*/

		protected var _decoder:JSONDecoder = new JSONDecoder();

		protected var _encoder:JSONEncoder = new JSONEncoder();

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function JSONClient(rootURL:String = "")
		{
			super(rootURL);
			addResultProcessor(resultProcessor);
			addParamsProcessor(paramsProcessor);
		}


		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function isPrimitive(source:*):Boolean
		{
			return source is String ||
				source is Number ||
				source is uint ||
				source is int ||
				source is Boolean ||
				source == null;
		}

		/*============================================================================*/
		/* Protected Functions                                                        */
		/*============================================================================*/

		protected function paramsProcessor(source:*):Object
		{
			if (source == null)
				return null;

			if (isPrimitive(source))
				return { value: source };

			if (source is Array)
				return { value: _encoder.encode(source)};

			source = source.valueOf();

			var property:String;
			var value:Object;
			var classInfo:XML = describeType(source);
			if (classInfo.@name.toString() == "Object")
			{
				// Dynamic Object
				for (property in source)
				{
					value = source[property];
					if (value is Function || isPrimitive(value))
						continue;
					source[property] = _encoder.encode(value);
				}
			}
			else
			{
				// Sealed Object
				for each (var v:XML in classInfo..*.(
					name() == "variable" ||
					(
					name() == "accessor" &&
					attribute("access").charAt(0) == "r")
					))
				{
					if (v.metadata && v.metadata.(@name == "Transient").length() > 0)
						continue;

					property = v.@name.toString();
					value = source[v.@name];
					if (value is Function || isPrimitive(value))
						continue;
					source[property] = _encoder.encode(value);
				}

			}

			return source;
		}

		protected function resultProcessor(data:*):Object // NO PMD
		{
			// Hack:
			if (data == '[]')
				return new ArrayCollection();
			if (data == '')
				return null;
			return _decoder.decode(String(data));
		}
	}
}