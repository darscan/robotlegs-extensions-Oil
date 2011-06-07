package org.robotlegs.oil.utils.object
{
	import flash.utils.describeType;
	
	/**
	 * Copy properties from one object into another.
	 * Sealed objects are copied into dynamic objects.
	 *
	 * @param source Object to copy properties from
	 * @param target (optional) Object to copy into. If null, a new object is created.
	 * @return A deep copy of the object
	 */
	public function copyAllProperties(source:Object, target:Object = null):Object
	{
		// Primitive
		if (source is String ||
			source is Number ||
			source is uint ||
			source is int ||
			source is Boolean ||
			source == null)
		{
			target = source;
			return target;
		}
		
		// Array
		if (source is Array)
		{
			var intoArray:Array = target as Array || [];
			var fromArray:Array = source as Array;
			var len:int = fromArray.length;
			for (var i:int = 0; i < len; i++)
				intoArray[i] = copyAllProperties(fromArray[i]);
			return intoArray;
		}
		
		// ObjectProxy
		if (source)
			source = source.valueOf();
		
		// Object
		target ||= {};
		var key:String;
		var value:Object;
		var classInfo:XML = describeType(source);
		if (classInfo.@name.toString() == "Object")
		{
			// Dynamic Object
			for (key in source)
			{
				value = source[key];
				if (value is Function)
					continue;
				
				target[key] = copyAllProperties(value);
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
				value = source[v.@name];
				target[key] = copyAllProperties(value);
			}
			
		}
		return target;
	}
}