package org.robotlegs.oil.pool
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import org.flexunit.Assert;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.adapters.SwiftSuspendersReflector;
	import org.robotlegs.base.CommandMap;
	import org.robotlegs.core.ICommandMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.oil.pool.support.CustomEvent;
	import org.robotlegs.oil.pool.support.CustomEventCommand;
	import org.robotlegs.oil.pool.support.ICommandTest;
	
	public class RecyclingCommandMapTests implements ICommandTest
	{		
		protected var eventDispatcher:IEventDispatcher;
		protected var commandExecuted:Boolean;
		protected var lastCommandExecutedInstance:Object;
		protected var payload:int;
		protected var commandMap:ICommandMap;
		protected var injector:IInjector;
		protected var reflector:IReflector;
		
		[Before]
		public function setUp():void
		{
			eventDispatcher = new EventDispatcher();
			injector = new SwiftSuspendersInjector();
			reflector = new SwiftSuspendersReflector();
			commandMap = new RecyclingCommandMap(eventDispatcher, injector, reflector);
			injector.mapValue(ICommandTest, this);
		}
		
		[After]
		public function tearDown():void
		{
			injector.unmap(ICommandTest);
			resetCommandExecuted();
			resetDataPayload();
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
		public function hasCommandForSpecifiedEventClass():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			var hasCommand:Boolean = commandMap.hasEventCommand(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			Assert.assertTrue('Command Map should have Command', hasCommand);
		}
		
		[Test]
		public function shouldNotHaveCommandForUnmappedEventClass():void
		{
			var unmappedEventClass:Class = MouseEvent;
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			var hasCommand:Boolean = commandMap.hasEventCommand(CustomEvent.STARTED, CustomEventCommand, unmappedEventClass);
			Assert.assertFalse('Command Map should not have Command for wrong event class', hasCommand);
		}
		
		[Test]
		public function normalCommand():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
		}
		
		[Test]
		public function dispatchingUnmappedEventClassShouldNotExecuteCommand():void
		{
			var unmappedEventClass:Class = MouseEvent;
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			eventDispatcher.dispatchEvent(new unmappedEventClass(CustomEvent.STARTED));
			Assert.assertFalse('Command should not have reponded to unmapped event', commandExecuted);
		}
		
		[Test]
		public function normalCommandRepeated():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
			resetCommandExecuted();
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event again', commandExecuted);
		}
		
		[Test]
		public function normalCommandRepeatedDeliversUniquePayloads():void
		{
			var payloadA:int = 42;
			var payloadB:int = 314159;
			
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED, payloadA));
			var receivedPayloadA:int = payload;
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
			Assert.assertTrue('Received payload A should match dispatched payload A', payloadA == receivedPayloadA);
			
			resetCommandExecuted();
			resetDataPayload();
			
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED, payloadB));
			var receivedPayloadB:int = payload;
			Assert.assertTrue('Command should have reponded to event again', commandExecuted);
			Assert.assertTrue('Received payload B should match dispatched payload B', payloadB == receivedPayloadB);
			
			Assert.assertTrue('The received payloads should differ if the sent payloads differed', (payloadA == payloadB) == (receivedPayloadA == receivedPayloadB)); 
		}
		
		[Test]
		public function normalCommandRepeatedReusesCommandInstance():void
		{
			var payloadA:int = 42;
			var payloadB:int = 314159;
			
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED, payloadA));
			Assert.assertNotNull('Command instance A detected', lastCommandExecutedInstance);
			var receivedPayloadA:int = payload;
			var commandInstanceA:Object = lastCommandExecutedInstance;
			
			resetCommandExecuted();
			resetDataPayload();
			
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED, payloadB));
			Assert.assertNotNull('Command instance B detected', lastCommandExecutedInstance);
			var receivedPayloadB:int = payload;
			var commandInstanceB:Object = lastCommandExecutedInstance;
			
			Assert.assertTrue('The received payloads should differ if the sent payloads differed', (payloadA == payloadB) == (receivedPayloadA == receivedPayloadB));
			Assert.assertTrue('Serial repeated triggering of the same command reuse the same instance', commandInstanceA == commandInstanceB);
		}
		
		[Test]
		public function oneshotCommandShouldBeRemovedAfterFirstExecution():void
		{
			var oneshot:Boolean = true;
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent, oneshot);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			var hasCommand:Boolean = commandMap.hasEventCommand(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			Assert.assertFalse('Command Map should NOT have oneshot Command after first execution', hasCommand);
		}
		
		[Test]
		public function oneshotCommandShouldNotExecuteASecondTime():void
		{
			var oneshot:Boolean = true;
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent, oneshot);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
			resetCommandExecuted();
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertFalse('Oneshot Command should NOT have reponded to event a second time', commandExecuted);
		}
		
		[Test]
		public function normalCommandRemoved():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
			resetCommandExecuted();
			commandMap.unmapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertFalse('Command should NOT have reponded to event', commandExecuted);
		}
		
		[Test]
		public function unmapEvents():void
		{
			commandMap.mapEvent(CustomEvent.EVENT0, CustomEventCommand, CustomEvent);
			commandMap.mapEvent(CustomEvent.EVENT1, CustomEventCommand, CustomEvent);
			commandMap.mapEvent(CustomEvent.EVENT2, CustomEventCommand, CustomEvent);
			commandMap.mapEvent(CustomEvent.EVENT3, CustomEventCommand, CustomEvent);
			commandMap.unmapEvents();
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.EVENT0));
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.EVENT1));
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.EVENT2));
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.EVENT3));
			Assert.assertFalse('Command should NOT have reponded to event', commandExecuted);
		}
		
		[Test(expects="org.robotlegs.base.ContextError")]
		public function mappingNonCommandClassShouldFail():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, Object, CustomEvent);
		}
		
		[Test(expects="org.robotlegs.base.ContextError")]
		public function mappingSameThingTwiceShouldFail():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
			commandMap.mapEvent(CustomEvent.STARTED, CustomEventCommand, CustomEvent);
		}
		
		public function markCommandExecuted(value:Object):void
		{
			commandExecuted = true;
			lastCommandExecutedInstance = value;
		}
		
		public function resetCommandExecuted():void
		{
			commandExecuted = false;
			lastCommandExecutedInstance = null;
		}
		
		public function resetDataPayload():void
		{
			payload = 0;
		}
		
		
		public function deliverDataPayload(value:int):void
		{
			payload = value;
		}
		
	}
}