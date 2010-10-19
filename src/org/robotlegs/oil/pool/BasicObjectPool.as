/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.pool
{
	
	public class BasicObjectPool implements IObjectPool
	{
		protected var instances:Array = new Array();
		protected var type:Class;
		
		public function BasicObjectPool(type:Class)
		{
			this.type = type;
		}
		
		public function put(object:Object):void
		{
			if (object is type)
			{
				instances.push(object);
			}
			else
				throw new ArgumentError("Object put in pool must be of type " + type);
		}
		
		public function get():Object
		{
			if (size > 0)
			{
				_objectsRecycled++;
				return instances.pop();
			}
			return create();
		}
		
		protected function create():Object
		{
			_objectsCreated++;
			return new type;
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
				put(create());
		}
		
		protected function shrink(n:uint):void
		{
			while (size > n)
				instances.pop();
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
		
		public function toString():String
		{
			return 'ObjectPool for type ' + type + ' - pool size: ' + size + ' - objects created: ' + _objectsCreated + ' - objects recycled: ' + _objectsRecycled;
		}
	}
}