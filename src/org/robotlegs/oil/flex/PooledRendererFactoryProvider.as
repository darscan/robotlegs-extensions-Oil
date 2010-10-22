/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.flex
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.oil.pool.InjectingObjectPool;
	
	public class PooledRendererFactoryProvider
	{
		protected var pools:Dictionary = new Dictionary();
		protected var injector:IInjector;
		
		public function PooledRendererFactoryProvider(injector:IInjector)
		{
			this.injector = injector;
		}
		
		public function getFactory(type:Class, id:String = '', properties:Object = null):PooledRendererFactory
		{
			var key:String = getQualifiedClassName(type) + id;
			return pools[key] ||= createPool(type, properties);
		}
		
		protected function createPool(type:Class, properties:Object = null):PooledRendererFactory
		{
			var pool:InjectingObjectPool = new InjectingObjectPool(injector, type, properties);
			return new PooledRendererFactory(pool);
		}
	
	}
}