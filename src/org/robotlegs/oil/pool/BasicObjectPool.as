/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.pool
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.robotlegs.oil.utils.object.copyProperties;
	
	public class BasicObjectPool extends EventDispatcher implements IObjectPool
	{
		protected var instances:Array = new Array();
		protected var type:Class;
		protected var properties:Object;
		
		public function BasicObjectPool(type:Class, properties:Object = null)
		{
			this.type = type;
			this.properties = properties;
		}
		
		public function put(object:Object):void
		{
			if (object is type)
				putObject(object);
			else
				throw new ArgumentError("Object put in pool must be of type " + type);
		}
		
		protected function putObject(object:Object):void
		{
			instances.push(object);
			dispatchEvent(new Event("sizeChange"));
		}
		
		public function get():Object
		{
			if (size > 0)
				return getObject()
			return createObject();
		}
		
		protected function getObject():Object
		{
			var object:Object = instances.pop();
			_objectsRecycled++;
			dispatchEvent(new Event("sizeChange"));
			dispatchEvent(new Event("objectsRecycledChange"));
			return object;
		}
		
		protected function createObject():Object
		{
			var object:Object = new type;
			_objectsCreated++;
			copyProperties(properties, object);
			dispatchEvent(new Event("objectsCreatedChange"));
			return object;
		}
		
		public function ensureSize(n:uint):void
		{
			if (size < n)
				grow(n);
			else
				shrink(n);
		}
		
		protected function grow(n:uint):void
		{
			while (size < n)
				put(createObject());
		}
		
		protected function shrink(n:uint):void
		{
			while (size > n)
				popObject();
		}
		
		protected function popObject():void
		{
			instances.pop();
			dispatchEvent(new Event("sizeChange"));
		}
		
		public function get size():uint
		{
			return instances.length;
		}
		
		protected var _objectsCreated:uint;
		
		public function get objectsCreated():uint
		{
			return _objectsCreated;
		}
		
		protected var _objectsRecycled:uint;
		
		public function get objectsRecycled():uint
		{
			return _objectsRecycled;
		}
		
		override public function toString():String
		{
			return 'ObjectPool for type ' + type + ' - pool size: ' + size + ' - objects created: ' + _objectsCreated + ' - objects recycled: ' + _objectsRecycled;
		}
	}
}