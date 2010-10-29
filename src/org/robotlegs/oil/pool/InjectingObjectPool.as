/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.pool
{
	import flash.events.Event;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.oil.utils.object.copyProperties;
	
	public class InjectingObjectPool extends BasicObjectPool
	{
		protected var injector:IInjector;
		
		public function InjectingObjectPool(injector:IInjector, type:Class, properties:Object = null)
		{
			super(type, properties);
			this.injector = injector;
		}
		
		override protected function createObject():Object
		{
			var instance:Object = injector.instantiate(type);
			_objectsCreated++;
			dispatchEvent(new Event("objectsCreatedChange"));			
			copyProperties(properties, instance);
			return instance;
		}
		
		override protected function getObject():Object
		{
			var object:Object = super.getObject();
			injector.injectInto(object);
			return object;
		}
	
	}
}
