package org.robotlegs.oil.utils.object
{
	import flash.utils.describeType;
	
	/**
	 * Copy properties from one object into another
	 *
	 * @param from Object to copy properties from
	 * @param into (optional) Object to copy into. If null, a new object is created.
	 * @return A one-level deep copy of the object or null if the argument is null
	 */
	public function copyStrongProps(from:Object, into:Object = null):Object
	{
		into ||= {};
		var p:String;
		var propertyList:XMLList = describeType(from)..variable;
		var propertyListLength:int = propertyList.length();
		if (propertyListLength > 0)
		{
			// For sealed objects
			for (var i:int; i < propertyListLength; i++)
			{
				p = propertyList[i].@name;
				into[p] = from[p];
			}
		}
		else
		{
			// For dynamic objects
			for (p in from)
				into[p] = from[p];
		}
		return into;
	}
}