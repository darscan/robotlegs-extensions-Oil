package org.robotlegs.oil.utils.object
{
	
	/**
	 * Copy properties from one dynamic object into another
	 *
	 * @param from Object to copy properties from
	 * @param into (optional) Object to copy into. If null, a new object is created.
	 * @return A one-level deep copy of the object
	 */
	public function copyProperties(from:Object, into:Object = null):Object
	{
		into ||= {};
		
		if (from != null)
			for (var p:String in from)
				into[p] = from[p];
		
		return into;
	}
}