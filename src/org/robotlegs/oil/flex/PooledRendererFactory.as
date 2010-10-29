/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.flex
{
	import flash.events.IEventDispatcher;
	
	import mx.core.IFactory;
	
	import org.robotlegs.oil.pool.IObjectPool;
	
	import spark.events.RendererExistenceEvent;
	
	public class PooledRendererFactory implements IFactory
	{
		private var _pool:IObjectPool;
		
		public function PooledRendererFactory(pool:IObjectPool)
		{
			_pool = pool;
		}
		
		public function get pool():IObjectPool
		{
			return _pool;
		}
		
		public function newInstance():*
		{
			return _pool.get();
		}
		
		public function itemRendererFunction(item:Object):IFactory
		{
			return this;
		}
		
		public function rendererRemoveHandler(event:RendererExistenceEvent):void
		{
			_pool.put(event.renderer);
		}
		
		public function manage(component:Object):void
		{
			// DataGroup, DropDownList and SkinnableDataContainer
			// do not share a common interface or base class
			if (component.hasOwnProperty("itemRenderer"))
				component.itemRenderer = this;
			
			if (component.hasOwnProperty("itemRendererFunction"))
				component.itemRendererFunction = itemRendererFunction;
			
			if (component is IEventDispatcher)
				component.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, rendererRemoveHandler, false, 0, true);
		}
	
	}
}