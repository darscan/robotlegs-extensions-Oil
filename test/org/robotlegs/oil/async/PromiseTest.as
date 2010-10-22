/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.oil.async
{
	import flexunit.framework.Assert;
	
	public class PromiseTest
	{
		private var promise:Promise;
		
		private var errorHandlerHitCount:int;
		private var progressHandlerHitCount:int;
		private var resultHandlerHitCount:int;
		
		[Before]
		public function setUp():void
		{
			promise = new Promise();
			
			errorHandlerHitCount = 0;
			progressHandlerHitCount = 0;
			resultHandlerHitCount = 0;
		}
		
		[After]
		public function tearDown():void
		{
			promise = null;
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
		public function testHandleFutureError():void
		{
			promise.addErrorHandler(supportErrorHandler);
			promise.handleError(null);
			Assert.assertTrue("Error handler should run", errorHandlerHitCount > 0);
		}
		
		[Test]
		public function testHandleOldError():void
		{
			promise.handleError(null);
			promise.addErrorHandler(supportErrorHandler);
			Assert.assertTrue("Error handler should run", errorHandlerHitCount > 0);
		}
		
		private function supportErrorHandler(p:Promise):void
		{
			errorHandlerHitCount++;
		}
		
		[Test]
		public function testHandleFutureProgress():void
		{
			promise.addProgressHandler(supportProgressHandler);
			promise.handleProgress(null);
			Assert.assertTrue("Progress handler should run", progressHandlerHitCount > 0);
		}
		
		[Test]
		public function testHandleOldProgress():void
		{
			promise.handleResult(null);
			promise.addProgressHandler(supportProgressHandler);
			Assert.assertTrue("Progress handler should run", progressHandlerHitCount > 0);
		}
		
		private function supportProgressHandler(p:Promise):void
		{
			progressHandlerHitCount++;
		}
		
		[Test]
		public function testHandleFutureResult():void
		{
			promise.addResultHandler(supportResultHandler);
			promise.handleResult(null);
			Assert.assertTrue("Result handler should run", resultHandlerHitCount > 0);
		}
		
		[Test]
		public function testHandleOldResult():void
		{
			promise.handleResult(null);
			promise.addResultHandler(supportResultHandler);
			Assert.assertTrue("Result handler should run", resultHandlerHitCount > 0);
		}
		
		private function supportResultHandler(p:Promise):void
		{
			resultHandlerHitCount++;
		}
		
		[Test]
		public function testGet_error():void
		{
			promise.handleError(0.5);
			Assert.assertEquals("Error should be set", 0.5, promise.error);
		}
		
		[Test]
		public function testGet_progress():void
		{
			promise.handleProgress(0.5);
			Assert.assertEquals("Progress should be set", 0.5, promise.progress);
		}
		
		[Test]
		public function testPromise():void
		{
			Assert.assertTrue("promise is Promise", promise is Promise);
		}
		
		[Test]
		public function testGet_result():void
		{
			promise.handleResult(0.5);
			Assert.assertEquals("Result should be set", 0.5, promise.result);
		}
		
		[Test]
		public function testGet_status():void
		{
			Assert.assertEquals("Status should start pending", Promise.PENDING, promise.status);
		}
		
		[Test]
		public function testCancel():void
		{
			promise.addErrorHandler(supportErrorHandler);
			promise.addProgressHandler(supportProgressHandler);
			promise.addResultHandler(supportResultHandler);
			promise.cancel();
			promise.handleError(null);
			promise.handleProgress(null);
			promise.handleResult(null);
			Assert.assertTrue("Error handler should NOT have run", errorHandlerHitCount == 0);
			Assert.assertTrue("Progress handler should NOT have run", progressHandlerHitCount == 0);
			Assert.assertTrue("Result handler should NOT have run", resultHandlerHitCount == 0);
		}
	}
}