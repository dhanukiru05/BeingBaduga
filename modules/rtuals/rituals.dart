import 'package:flutter/material.dart';

// Define an enumeration for the supported languages
enum Language { Baduga, Tamil, English }

class RitualsPage extends StatefulWidget {
  @override
  _RitualsPageState createState() => _RitualsPageState();
}

class _RitualsPageState extends State<RitualsPage> {
  // Variable to hold the currently selected language
  Language _selectedLanguage = Language.Baduga;

  // Sample data with Baduga, Tamil, and English translations
  final List<Map<String, String>> _rituals = [
    {
      'baduga': '1.அகதலெ மண்ணு நுடிதலெ மாத்து',
      'tamil': '1.தோண்டினால் மண், \n பேசினால் தொடர் பேச்சு',
      'english': '1. If one digs endless soil,\nIf one talks endless verbiage.'
    },

    {
      'baduga': '2. அங்க/நங்க ஒள்ளித்தாலே \n நாடொள்ளித்து',
      'tamil': '2.நாம் நல்லவர்களானால் நாடும் நல்லது',
      'english': '2. If we are good all other\n will be good.'
    },
    {
      'baduga': '3.அங்க பெள்ளி ஹொல்லாதோலே\n தட்டனகோட ஹோராட்ட ஏனக?',
      'tamil':
          '3.நம் வெள்ளி (உலோகம்) சரியற்றதானால்\n பொற்கொல்லனிடம் தகராறு எதற்கு?',
      'english':
          '3. Our silver is of low purity;\nthen why quarrel with goldsmith?.'
    },
    {
      'baduga': '4.அன்னெயத சொத்து மம்ம மக்கக இல்லெ',
      'tamil':
          '4.அக்ரம வழியில் வரும் செல்வம் \nபேரக்குழந்தைகளுக்கு போய்ச்சேராது',
      'english':
          '4.Property acquried by improper\n mean will not remain to\n passed on to grand Childern.'
    },
    {
      'baduga': '5அரசு அந்து அரிதர தேவரு \nநித்தரிதர',
      'tamil': '5.அரசு அன்று கொல்லும் தெய்வம் \n நின்று கொல்லும்',
      'english': '5.The kings punishment is peremptory \n That of God late..'
    },
    {
      'baduga': '6.அறிது ஆறாவ கேப்பது முத்தவரு \nமூராவ கேப்பது',
      'tamil':
          '6.அறிந்தாலும் ஆறு பேரைக் கேட்க \n வேண்டும், அனுபவசாலிகள் மூவரை \n கேட்க வேண்டும்',
      'english':
          '6.Though you know get advice \n from six person;\nThough you are experienced \n get advice from three.'
    },
    {
      'baduga': '7.அவ்வெ அப்பன தவிர பேரெ \n எல்லாவ ஈசாக்கு',
      'tamil': '7.தாயும் தகப்பனும் தவிர வேறு \nஎல்லாவற்றையும் வாங்கலாம்',
      'english': '7.One can buy anything except\n ones mother and father.'
    },
    {
      'baduga': '8.ஆதாடித கொட்டகெ ஹொல்ல,\n ஹூதாடித மனெ ஹொல்ல',
      'tamil':
          '8.முட்டுதல் நிகழும் தொழுவம் நல்லதல்ல \nஅடிதடி நிகழும் வீடு நல்லதல்ல.',
      'english':
          '8. Butting at the manger \nis no good; quarrelling at home \nis no good.'
    },
    {
      'baduga': '9.உண்ட/திந்த மனெக எரடு \n எத்த பேட',
      'tamil': '9.உண்ட வீட்டிற்கு இரண்டகம்  \n நினைக்க வேண்டாம்',
      'english':
          '9. Do not be treacherous to \n the home that nurtured you \n(Mid not the fountain that\n gave drink to thee).'
    },
    {
      'tamil': '10. சாவிட சேர் பே சுண்டுகள்\n ஒரு பே',
      'english': '10. No back biting and\n no gossip.'
    },
    {
      'tamil': '11. சாவு பரந்தன கா ச்சே',
      'english':
          '11. When a gentle saint angry\n even a forest cannot withstand \nhis wrath.  .'
    },
    {
      'tamil': '12. சாமு மாடி வொனான்மா பே  ',
      'english': '12.Do not cultivate with \nborrowed money  .'
    },
    {
      'tamil': '13. ஆவி வருது ஆணை சவுதபா',
      'english':
          '13. Even, if one lives a thousand \nyears, he cannot escape death \n(Death is the common lot \nof all) .'
    },
    {
      'tamil': '14. . தந்தை மிரு மக்களேல், \nமிரு மிரு மக்களேல்  ',
      'english':
          '14. The son who disobeys his \nfather is like the teeth \nwhich protrudes.  .'
    },
    {
      'tamil': '15. தன் ஊருக்கு ஆழ் அமானத்தான்  ',
      'english': '15.    Dishonor to ones village is \n disonor to him.  .'
    },
    {
      'tamil': '16. தாய் பாகி ஹோரக்  ',
      'english': '16.  Bow your head always\n (be humble) .'
    },
    {
      'tamil': '17. தின் மனைத்து துரா பே  ',
      'english': '17. Do not abuse the house \n which fed you  .'
    },
    {
      'tamil':
          '18. தாய் மாட்டுக்கு நோடாதம் நே, \n தந்தை மாட்டுக்கு நோடாதம் பே.',
      'english':
          '18. A child that does not \n obey its mother is a dog,\n One that does not obey his father, \n is a devil.'
    },
    {
      'tamil': '19.துஞ்சுமாத கண்ணடேகப்;\n ஹாதாரா ஹேண்ணு கடேகப்  ',
      'english': '19. Man ruined by obstinacy, \n woman by loitering.'
    },
    {
      'tamil': '20. துட்டட மதி மந்தி கிழ்மறுகி  ',
      'english': '20. Eat your food unobtrusively, \n same for defecation.'
    },
    {
      'tamil': '21. நொளவக்கள் ஹோமா; \n ஹோமா கண்ணேகன்',
      'english':
          '21.Adult feel hunger in their stomach,\n children felt it in their eyes.'
    },
    {
      'tamil': '22. நாங்கள் நாங்கள் விடுபட',
      'english':
          '22. Our shadow will never leave us.\n (i.e. we cannot escape from the \n effects of our crimes and \n short coming).  '
    },
    {
      'tamil': '23. நடுநாள் ஆளும் கெளவுதும்',
      'english':
          '23.Giving alms to the deserving,\n it is folly to give to others.'
    },
    {
      'tamil': '24. நீரன் கலைநீர் திசை',
      'english': '24.Water cleanses its impurities \n by itself.'
    },
    {
      'tamil': '25. படவன களுகார ஹோமா\n மலைத்தன தேதா',
      'english': '25.   If the strong beats the poor,\n god beats the strong.'
    },
    {
      'tamil': '26.நெத்தீய பற கெத்திலே ஹோறா?',
      'english':
          '26. Can you just shave off the \n lines recording you fate on the \n forehead (head) at birth.'
    },
    {
      'tamil':
          '27. பட்டுப்பித்தின் குதிரை காய்ந்தால் எதற்கு,\n கெட்டுமொழி கெட்டால் எதற்கு',
      'english':
          '27. When you are prosperous even \nthe wild elephant salutes; \n When you are ruined even an \n ant throws dirt.'
    },
    {
      'tamil': '28. பட்டிக்கூட கயிறு கயிறு',
      'english': '28.What is spent on clothes \n is more waste.'
    },
    {
      'tamil': '29.பிதன பசுமை போல்',
      'english':
          '29. The light of the stars.\n The wealth of childless man \n goes waste.'
    },
    {
      'tamil': '30. பசிக்குக் கால் தம்பியால் சாகும் \n தம்பி',
      'english': '30. Prosperity may escape one,\n But death will not.'
    },
    {
      'tamil': '31. பிதவிக்கே ஒருதலைவனே இல்லையே ',
      'english': '31. He who forgot to sow will \n have nothing to reap.'
    },
    {
      'tamil': '32. இமாசி வெள்ளச்சி வலியிலே பட்டே',
      'english': '32.Fools talk ended in \n blows on the back.'
    },
    {
      'tamil': '33. மெல்லி எந்து மெல்லி மொன்றினம்',
      'english': '33.Like the hedge grazing the crop.'
    },
    {
      'tamil': '34. கும்மேலே நொய்யா காயரா?',
      'english':
          '34.Will any fool cut his \n thigh because his child \n defecated on it?'
    },
    {
      'tamil': '35. மதியிலே இல்லாத ஊர்க்கு \n மந்தேசன் இன் பாட்டே',
      'english': '35.Do not live in a village \n without a no impartial leader.'
    },
    {
      'tamil': '36. மனயோ நுழுது மந்தகோ',
      'english': '36.Make up your mind at \n home and then go to assembly.'
    },
    {
      'tamil': '37.கட்கோய்பட்டில திட்கொண்டமா ணன',
      'english': '37.He who diverts anger is \n intelligent.'
    },
    {
      'tamil': '38. சம்பு முரிந்து வெள்ளுத்து \n தின்ன பே',
      'english':
          '38.Because the sugar-cane is sweet,\n do not eat up to the root.\n(The orange that is too hard \n squeezed yields bitter juice)'
    },
    {
      'tamil': '39. தீச்சீதமன மனை கனி,\n பித்தகன மனை சி',
      'english':
          '39.The house of (the miserly) \n rich is empty,\n The house of the learned \n man is cheerful.'
    },
    {
      'tamil': '40. கணில் ஹோசமா மா யா',
      'english': '40.Go to work in early morning \n and return by evening.'
    },
    {
      'tamil': '41. கிடத்துதன சுடலதம',
      'english': '41.Forget which is not attained.'
    },
    {
      'tamil': '42. சீக்கோண சுட் ஹானு ஆரி \n மாத்துனு சுட் ஹண்ணு ஆ',
      'english':
          '42.Wound caused by fire will heal.\n But wound caused by insulting \n words will never heal.'
    },
    {
      'tamil': '43. கை கெட்டுப் பேக மொச்சு',
      'english':
          '43.The hand toils; \n the mouth gets curd \n (tasty food) (No miles no meals)'
    },
    {
      'tamil': '44. கொட்டுக் கெட்டுமலினம், \n கொட்டாத கெட்டுமலினம்',
      'english':
          '44.Alms - giving never made \n any man poor nor stinginess \n made one prosper.'
    },
    {
      'tamil': '45. கொஞ்சது கெட்டாரா இல்லையே, \n கொஞ்சகமல் செல்வா ஆண்களும்வை',
      'english': '45.Even going to plunder  \n dont go with partner'
    },
    // ... add more as needed
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rituals'),
        actions: [
          // PopupMenuButton to select between Baduga, Tamil, and English
          PopupMenuButton<Language>(
            icon: Icon(Icons.language),
            onSelected: (Language language) {
              setState(() {
                _selectedLanguage = language;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Language>>[
              PopupMenuItem<Language>(
                value: Language.Baduga,
                child: Text('Baduga'),
              ),
              PopupMenuItem<Language>(
                value: Language.Tamil,
                child: Text('தமிழ்'),
              ),
              PopupMenuItem<Language>(
                value: Language.English,
                child: Text('English'),
              ),
            ],
            tooltip: 'Select Language',
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _rituals.length,
          itemBuilder: (context, index) {
            final ritual = _rituals[index];

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baduga Translation
                  if (ritual.containsKey('baduga'))
                    _buildTranslationRow(
                      label: 'Baduga',
                      text: ritual['baduga']!,
                    ),
                  // Tamil Translation
                  if (ritual.containsKey('tamil'))
                    _buildTranslationRow(
                      label: 'தமிழ்',
                      text: ritual['tamil']!,
                    ),
                  // English Translation
                  if (ritual.containsKey('english'))
                    _buildTranslationRow(
                      label: 'English',
                      text: ritual['english']!,
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Display a SnackBar with information based on the selected language
          String infoText;
          switch (_selectedLanguage) {
            case Language.Baduga:
              infoText = 'Baduga: மொழி';
              break;
            case Language.Tamil:
              infoText = 'மொழி: தமிழ்';
              break;
            case Language.English:
              infoText = 'Language: English';
              break;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(infoText),
            ),
          );
        },
        child: Icon(Icons.info),
        tooltip: _getTooltipForFAB(),
      ),
    );
  }

  /// Helper method to build each translation row
  Widget _buildTranslationRow({required String label, required String text}) {
    bool isSelectedLanguage = false;
    switch (label) {
      case 'Baduga':
        isSelectedLanguage = _selectedLanguage == Language.Baduga;
        break;
      case 'தமிழ்':
        isSelectedLanguage = _selectedLanguage == Language.Tamil;
        break;
      case 'English':
        isSelectedLanguage = _selectedLanguage == Language.English;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16,
            color: isSelectedLanguage ? Colors.blueAccent : Colors.black87,
            fontWeight:
                isSelectedLanguage ? FontWeight.bold : FontWeight.normal,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelectedLanguage ? Colors.blueAccent : Colors.black87,
              ),
            ),
            TextSpan(
              text: text,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get the tooltip text for the FloatingActionButton
  String _getTooltipForFAB() {
    switch (_selectedLanguage) {
      case Language.Baduga:
        return 'தகவல்:  மொழி';
      case Language.Tamil:
        return 'தகவல்';
      case Language.English:
        return 'Information';
      default:
        return 'Information';
    }
  }
}
