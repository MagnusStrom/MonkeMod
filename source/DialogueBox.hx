package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeftNormal:FlxSprite;
	var portraitLeftHappy:FlxSprite;
	var portraitLeftSad:FlxSprite;
	var portraitLem:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);

		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'swing':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);//speech bubble normal
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, false);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
		}

		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		portraitLeftNormal = new FlxSprite(-300, 300).loadGraphic(Paths.image('Normal'));
		portraitLeftNormal.updateHitbox();
		portraitLeftNormal.scrollFactor.set();
		add(portraitLeftNormal);
		portraitLeftNormal.visible = false;

		portraitLeftHappy = new FlxSprite(-300, 300).loadGraphic(Paths.image('Happy'));
		portraitLeftHappy.updateHitbox();
		portraitLeftHappy.scrollFactor.set();
		add(portraitLeftHappy);
		portraitLeftHappy.visible = false;

		portraitLeftSad = new FlxSprite(-300, 300).loadGraphic(Paths.image('Sad'));
		portraitLeftSad.updateHitbox();
		portraitLeftSad.scrollFactor.set();
		add(portraitLeftSad);
		portraitLeftSad.visible = false;

		portraitRight = new FlxSprite(750, 250);
		portraitRight.loadGraphic(Paths.image('bftext'));
		portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.08));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		portraitLem = new FlxSprite(-300, 300).loadGraphic(Paths.image('Lemming'));
		portraitLem.updateHitbox();
		portraitLem.scrollFactor.set();
		add(portraitLem);
		portraitLem.visible = false;

		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.15));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		box.y += 400;

		portraitLeftNormal.screenCenter(X);
		portraitLeftHappy.screenCenter(X);
		portraitLeftSad.screenCenter(X);
		portraitLem.screenCenter(X);
		portraitRight.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
//		add(handSelect);

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 550, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.setFormat("HappyMonkey-Regular.ttf", 32, FlxColor.BLACK);
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
		dropText.visible = false;
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;
		

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true)
		{
			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeftSad.visible = false;
						portraitLeftHappy.visible = false;
						portraitLeftNormal.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'normal':
				box.flipX = true;
				portraitRight.visible = false;
				portraitLeftSad.visible = false;
				portraitLeftHappy.visible = false;
				if (!portraitLeftNormal.visible)
				{
					portraitLeftNormal.visible = true;
				}
			case 'sad':
				box.flipX = true;
				portraitRight.visible = false;
				portraitLeftHappy.visible = false;
				portraitLeftNormal.visible = false;
				if (!portraitLeftSad.visible)
				{
					portraitLeftSad.visible = true;
				}
			case 'happy':
				box.flipX = true;
				portraitRight.visible = false;
				portraitLeftSad.visible = false;
				portraitLeftNormal.visible = false;
				if (!portraitLeftHappy.visible)
				{
					portraitLeftHappy.visible = true;
				}
			case 'lemming':
				box.flipX = true;
				portraitRight.visible = false;
				portraitLeftSad.visible = false;
				portraitLeftHappy.visible = false;
				portraitLeftNormal.visible = false;
				if (!portraitLem.visible)
				{
					portraitLem.visible = true;
				}
			case 'bf':
				box.flipX = false;
				portraitLeftSad.visible = false;
				portraitLeftHappy.visible = false;
				portraitLeftNormal.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
		}
		/*
								portraitLeftSad.visible = false;
						portraitLeftHappy.visible = false;
						portraitLeftNormal.visible = false;*/
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
