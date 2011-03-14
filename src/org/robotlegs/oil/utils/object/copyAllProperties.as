package org.robotlegs.oil.utils.object
{
	import flash.utils.describeType;
	
	/**
	 * Copy properties from one object into another.
	 * Sealed objects are copied into dynamic objects.
	 *
	 * @param from Object to copy properties from
	 * @param into (optional) Object to copy into. If null, a new object is created.
	 * @return A deep copy of the object
	 */
	public function copyAllProperties(from:Object, into:Object = null):Object
	{
		// Primitive
		if (from is String ||
			from is Number ||
			from is uint ||
			from is int ||
			from is Boolean ||
			from == null)
		{
			into = from;
			return into;
		}
		
		// Array
		if (from is Array)
		{
			var intoArray:Array = into as Array || [];
			var fromArray:Array = from as Array;
			var len:int = fromArray.length;
			for (var i:int = 0; i < len; i++)
				intoArray[i] = copyAllProperties(fromArray[i]);
			return intoArray;
		}
		
		// ObjectProxy
		if (from)
			from = from.valueOf();
		
		// Object
		into ||= {};
		var key:String;
		var value:Object;
		var classInfo:XML = describeType(from);
		if (classInfo.@name.toString() == "Object")
		{
			// Dynamic Object
			for (key in from)
			{
				value = from[key];
				if (value is Function)
					continue;
				
				into[key] = copyAllProperties(value);
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
				
				key = v.@name.toString();
				value = from[v.@name];
				into[key] = copyAllProperties(value);
			}
			
		}
		return into;
	}
}