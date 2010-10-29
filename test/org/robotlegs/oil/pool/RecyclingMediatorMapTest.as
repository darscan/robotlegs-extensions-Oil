package org.robotlegs.oil.pool
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import flexunit.framework.Assert;
	
	import mx.core.UIComponent;
	
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.adapters.SwiftSuspendersReflector;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.oil.pool.support.TestContextView;
	import org.robotlegs.oil.pool.support.TestContextViewMediator;
	import org.robotlegs.oil.pool.support.ViewComponent;
	import org.robotlegs.oil.pool.support.ViewComponentAdvanced;
	import org.robotlegs.oil.pool.support.ViewMediator;
	import org.robotlegs.oil.pool.support.ViewMediatorAdvanced;

	public class RecyclingMediatorMapTest
	{		
		protected var contextView:DisplayObjectContainer;
		protected var eventDispatcher:IEventDispatcher;
		protected var commandExecuted:Boolean;
		protected var mediatorMap:RecyclingMediatorMap;
		protected var injector:IInjector;
		protected var reflector:IReflector;		
		
		[Before]
		public function setUp():void
		{
			contextView = new TestContextView();
			eventDispatcher = new EventDispatcher();
			injector = new SwiftSuspendersInjector();
			reflector = new SwiftSuspendersReflector();
			mediatorMap = new RecyclingMediatorMap(contextView, injector, reflector);
			
			injector.mapValue(DisplayObjectContainer, contextView);
			injector.mapValue(IInjector, injector);
			injector.mapValue(IEventDispatcher, eventDispatcher);
			injector.mapValue(IMediatorMap, mediatorMap);
			
			UIImpersonator.addChild(contextView);
		}
		
		[After]
		public function tearDown():void
		{
			UIImpersonator.removeAllChildren();
			injector.unmap(IMediatorMap);
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function mediatorIsMappedAndCreatedForView():void
		{
			mediatorMap.mapView(ViewComponent, ViewMediator, null, false, false);
			var viewComponent:ViewComponent = new ViewComponent();
			contextView.addChild(viewComponent);
			var mediator:IMediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created ', mediator);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
		}
		
		[Test]
		public function mediatorIsMappedAndCreatedWithInjectViewAsClass():void {
			mediatorMap.mapView(ViewComponent, ViewMediator, ViewComponent, false, false);
			var viewComponent:ViewComponent = new ViewComponent();
			contextView.addChild(viewComponent);
			var mediator:IMediator = mediatorMap.createMediator(viewComponent);
			var exactMediator:ViewMediator = mediator as ViewMediator;
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created of the exact desired class', mediator is ViewMediator);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			Assert.assertNotNull('View Component should have been injected into Mediator', exactMediator.view);
			Assert.assertTrue('View Component injected should match the desired class type', exactMediator.view is ViewComponent);
		}
		
		[Test]
		public function mediatorIsMappedAndCreatedWithInjectViewAsArrayOfSameClass():void {
			mediatorMap.mapView(ViewComponent, ViewMediator, [ViewComponent], false, false);
			var viewComponent:ViewComponent = new ViewComponent();
			contextView.addChild(viewComponent);
			var mediator:IMediator = mediatorMap.createMediator(viewComponent);
			var exactMediator:ViewMediator = mediator as ViewMediator;
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created of the exact desired class', mediator is ViewMediator);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			Assert.assertNotNull('View Component should have been injected into Mediator', exactMediator.view);
			Assert.assertTrue('View Component injected should match the desired class type', exactMediator.view is ViewComponent);
		}
		
		[Test]
		public function mediatorIsMappedAndCreatedWithInjectViewAsArrayOfRelatedClass():void {
			mediatorMap.mapView(ViewComponentAdvanced, ViewMediatorAdvanced, [ViewComponent, ViewComponentAdvanced], false, false);
			var viewComponentAdvanced:ViewComponentAdvanced = new ViewComponentAdvanced();
			contextView.addChild(viewComponentAdvanced);
			var mediator:IMediator = mediatorMap.createMediator(viewComponentAdvanced);
			var exactMediator:ViewMediatorAdvanced = mediator as ViewMediatorAdvanced;
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created of the exact desired class', mediator is ViewMediatorAdvanced);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponentAdvanced));
			Assert.assertNotNull('First Class in the "injectViewAs" array should have been injected into Mediator', exactMediator.view);
			Assert.assertNotNull('Second Class in the "injectViewAs" array should have been injected into Mediator', exactMediator.viewAdvanced);
			Assert.assertTrue('First Class injected via the "injectViewAs" array should match the desired class type', exactMediator.view is ViewComponent);
			Assert.assertTrue('Second Class injected via the "injectViewAs" array should match the desired class type', exactMediator.viewAdvanced is ViewComponentAdvanced);
		}
		
		
		[Test]
		public function mediatorIsMappedAddedAndRemoved():void
		{
			var viewComponent:ViewComponent = new ViewComponent();
			var mediator:IMediator;
			
			mediatorMap.mapView(ViewComponent, ViewMediator, null, false, false);
			contextView.addChild(viewComponent);
			mediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediator));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			mediatorMap.removeMediator(mediator);
			Assert.assertFalse("Mediator Should Not Exist", mediatorMap.hasMediator(mediator));
			Assert.assertFalse("View Mediator Should Not Exist", mediatorMap.hasMediatorForView(viewComponent));
		}
		
		[Test]
		public function mediatorIsMappedAddedAndRemovedByView():void
		{
			var viewComponent:ViewComponent = new ViewComponent();
			var mediator:IMediator;
			
			mediatorMap.mapView(ViewComponent, ViewMediator, null, false, false);
			contextView.addChild(viewComponent);
			mediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediator));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			mediatorMap.removeMediatorByView(viewComponent);
			Assert.assertFalse("Mediator should not exist", mediatorMap.hasMediator(mediator));
			Assert.assertFalse("View Mediator should not exist", mediatorMap.hasMediatorForView(viewComponent));
		}
		
		[Test]
		public function mediatorIsRecycled():void
		{
			var viewComponentA:ViewComponent = new ViewComponent();
			var viewComponentB:ViewComponent = new ViewComponent();
			var mediatorA:IMediator;
			var mediatorB:IMediator;
			
			mediatorMap.mapView(ViewComponent, ViewMediator, null, false, false);
			contextView.addChild(viewComponentA);
			mediatorA = mediatorMap.createMediator(viewComponentA);
			Assert.assertNotNull('Mediator should have been created', mediatorA);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediatorA));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponentA));
			Assert.assertTrue('Mediator should currently reference View Component A', mediatorA.getViewComponent() == viewComponentA);
			mediatorMap.removeMediatorByView(viewComponentA);
			Assert.assertFalse("Mediator should not be registered as active", mediatorMap.hasMediator(mediatorA));
			Assert.assertFalse("View Mediator should not be registered as active", mediatorMap.hasMediatorForView(viewComponentA));
			
			contextView.addChild(viewComponentB);
			mediatorB = mediatorMap.createMediator(viewComponentB);
			Assert.assertNotNull('Mediator should have been created', mediatorB);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediatorB));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponentB));
			Assert.assertTrue('Mediator should currently reference View Component A', mediatorB.getViewComponent() == viewComponentB);
			
			Assert.assertTrue('Mediator should be the same instance as created for the first view component', mediatorA == mediatorB);
			
			mediatorMap.removeMediatorByView(viewComponentB);
			Assert.assertFalse("Mediator should not be registered as active", mediatorMap.hasMediator(mediatorB));
			Assert.assertFalse("View Mediator should not be registered as active", mediatorMap.hasMediatorForView(viewComponentB));
		}
		
		[Test]
		public function autoRegister():void
		{
			mediatorMap.mapView(ViewComponent, ViewMediator, null, true, true);
			var viewComponent:ViewComponent = new ViewComponent();
			contextView.addChild(viewComponent);
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
		}
		
		[Test(async, timeout='500')]
		public function mediatorIsKeptDuringReparenting():void
		{
			var viewComponent:ViewComponent = new ViewComponent();
			var mediator:IMediator;
			
			mediatorMap.mapView(ViewComponent, ViewMediator, null, false, true);
			contextView.addChild(viewComponent);
			mediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediator));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			var container:UIComponent = new UIComponent();
			contextView.addChild(container);
			container.addChild(viewComponent);
			
			Async.handleEvent(this, contextView, Event.ENTER_FRAME, delayFurther, 500, {dispatcher: contextView, method: verifyMediatorSurvival, view: viewComponent, mediator: mediator});
		}
		
		private function verifyMediatorSurvival(event:Event, data:Object):void
		{
			var viewComponent:ViewComponent = data.view;
			var mediator:IMediator = data.mediator;
			Assert.assertTrue("Mediator should exist", mediatorMap.hasMediator(mediator));
			Assert.assertTrue("View Mediator should exist", mediatorMap.hasMediatorForView(viewComponent));
		}
		
		[Test(async, timeout='500')]
		public function mediatorIsRemovedWithView():void
		{
			var viewComponent:ViewComponent = new ViewComponent();
			var mediator:IMediator;
			
			mediatorMap.mapView(ViewComponent, ViewMediator, null, false, true);
			contextView.addChild(viewComponent);
			mediator = mediatorMap.createMediator(viewComponent);
			Assert.assertNotNull('Mediator should have been created', mediator);
			Assert.assertTrue('Mediator should have been created', mediatorMap.hasMediator(mediator));
			Assert.assertTrue('Mediator should have been created for View Component', mediatorMap.hasMediatorForView(viewComponent));
			
			contextView.removeChild(viewComponent);
			Async.handleEvent(this, contextView, Event.ENTER_FRAME, delayFurther, 500, {dispatcher: contextView, method: verifyMediatorRemoval, view: viewComponent, mediator: mediator});
		}
		
		private function verifyMediatorRemoval(event:Event, data:Object):void
		{
			var viewComponent:ViewComponent = data.view;
			var mediator:IMediator = data.mediator;
			Assert.assertFalse("Mediator should not exist", mediatorMap.hasMediator(mediator));
			Assert.assertFalse("View Mediator should not exist", mediatorMap.hasMediatorForView(viewComponent));
		}
		
		private function delayFurther(event:Event, data:Object):void
		{
			Async.handleEvent(this, data.dispatcher, Event.ENTER_FRAME, data.method, 500, data);
			delete data.dispatcher;
			delete data.method;
		}
		
		[Test]
		public function contextViewMediatorIsCreatedWhenMapped():void
		{
			mediatorMap.mapView( TestContextView, TestContextViewMediator );
			Assert.assertTrue('Mediator should have been created for contextView', mediatorMap.hasMediatorForView(contextView));
		}
		
		[Test]
		public function contextViewMediatorIsNotCreatedWhenMappedAndAutoCreateIsFalse():void
		{
			mediatorMap.mapView( TestContextView, TestContextViewMediator, null, false );
			Assert.assertFalse('Mediator should NOT have been created for contextView', mediatorMap.hasMediatorForView(contextView));
		}
		
		[Test]
		public function unmapView():void
		{
			mediatorMap.mapView(ViewComponent, ViewMediator);
			mediatorMap.unmapView(ViewComponent);
			var viewComponent:ViewComponent = new ViewComponent();
			contextView.addChild(viewComponent);
			var hasMediator:Boolean = mediatorMap.hasMediatorForView(viewComponent);
			Assert.assertFalse('Mediator should NOT have been created for View Component', hasMediator);
		}
	}
}