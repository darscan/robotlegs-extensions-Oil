/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.flex
{
	import mx.core.IFactory;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.oil.utils.object.copyProperties;
	
	public class InjectingFactory implements IFactory
	{
		protected var injector:IInjector;
		protected var type:Class;
		protected var properties:Object;
		
		/**
		 * An IFactory implementation that instantiates instances from an injector
		 *
		 * @param injector The Injector to create instances with
		 * @param type The Class to create instances from
		 * @param properties (Optional) Properties to apply to newly created instances
		 */
		public function InjectingFactory(injector:IInjector, type:Class, properties:Object = null)
		{
			this.injector = injector;
			this.type = type;
			this.properties = properties;
		}
		
		public function newInstance():* // NO PMD
		{
			var instance:Object = injector.instantiate(type);
			copyProperties(properties, instance);
			return instance;
		}
	}
}