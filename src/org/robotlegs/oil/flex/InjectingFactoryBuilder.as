/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.flex
{
	import org.robotlegs.core.IInjector;
	
	public class InjectingFactoryBuilder
	{
		protected var injector:IInjector;
		
		/**
		 * Builds InjectingFactories pre-configured with an Injector
		 *
		 * @param injector The Injector to provide to each InjectingFactory
		 */
		public function InjectingFactoryBuilder(injector:IInjector)
		{
			this.injector = injector;
		}
		
		/**
		 * Builds an InjectingFactory pre-configured with an Injector
		 *
		 * @param type The Class to create instances from
		 * @param properties (Optional) Properties to apply to newly created instances
		 * @return The pre-configured InjectingFactory
		 */
		public function build(type:Class, properties:Object = null):InjectingFactory
		{
			return new InjectingFactory(injector, type, properties);
		}
	
	}

}
