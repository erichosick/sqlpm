/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- iso_seed_alpha2 - run
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

WITH import (doc) AS (
  VALUES ('
[
  {
    "label": "Afar",
    "language_alpha2_id": "aa"
  },
  {
    "label": "Abkhazian",
    "language_alpha2_id": "ab"
  },
  {
    "label": "Avestan",
    "language_alpha2_id": "ae"
  },
  {
    "label": "Afrikaans",
    "language_alpha2_id": "af"
  },
  {
    "label": "Akan",
    "language_alpha2_id": "ak"
  },
  {
    "label": "Amharic",
    "language_alpha2_id": "am"
  },
  {
    "label": "Aragonese",
    "language_alpha2_id": "an"
  },
  {
    "label": "Arabic",
    "language_alpha2_id": "ar"
  },
  {
    "label": "Assamese",
    "language_alpha2_id": "as"
  },
  {
    "label": "Avaric",
    "language_alpha2_id": "av"
  },
  {
    "label": "Aymara",
    "language_alpha2_id": "ay"
  },
  {
    "label": "Azerbaijani",
    "language_alpha2_id": "az"
  },
  {
    "label": "Bashkir",
    "language_alpha2_id": "ba"
  },
  {
    "label": "Belarusian",
    "language_alpha2_id": "be"
  },
  {
    "label": "Bulgarian",
    "language_alpha2_id": "bg"
  },
  {
    "label": "Bihari languages",
    "language_alpha2_id": "bh"
  },
  {
    "label": "Bislama",
    "language_alpha2_id": "bi"
  },
  {
    "label": "Bambara",
    "language_alpha2_id": "bm"
  },
  {
    "label": "Bengali",
    "language_alpha2_id": "bn"
  },
  {
    "label": "Tibetan",
    "language_alpha2_id": "bo"
  },
  {
    "label": "Breton",
    "language_alpha2_id": "br"
  },
  {
    "label": "Bosnian",
    "language_alpha2_id": "bs"
  },
  {
    "label": "Catalan; Valencian",
    "language_alpha2_id": "ca"
  },
  {
    "label": "Chechen",
    "language_alpha2_id": "ce"
  },
  {
    "label": "Chamorro",
    "language_alpha2_id": "ch"
  },
  {
    "label": "Corsican",
    "language_alpha2_id": "co"
  },
  {
    "label": "Cree",
    "language_alpha2_id": "cr"
  },
  {
    "label": "Czech",
    "language_alpha2_id": "cs"
  },
  {
    "label": "Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic",
    "language_alpha2_id": "cu"
  },
  {
    "label": "Chuvash",
    "language_alpha2_id": "cv"
  },
  {
    "label": "Welsh",
    "language_alpha2_id": "cy"
  },
  {
    "label": "Danish",
    "language_alpha2_id": "da"
  },
  {
    "label": "German",
    "language_alpha2_id": "de"
  },
  {
    "label": "Divehi; Dhivehi; Maldivian",
    "language_alpha2_id": "dv"
  },
  {
    "label": "Dzongkha",
    "language_alpha2_id": "dz"
  },
  {
    "label": "Ewe",
    "language_alpha2_id": "ee"
  },
  {
    "label": "Greek, Modern (1453-)",
    "language_alpha2_id": "el"
  },
  {
    "label": "label",
    "language_alpha2_id": "en"
  },
  {
    "label": "Esperanto",
    "language_alpha2_id": "eo"
  },
  {
    "label": "Spanish; Castilian",
    "language_alpha2_id": "es"
  },
  {
    "label": "Estonian",
    "language_alpha2_id": "et"
  },
  {
    "label": "Basque",
    "language_alpha2_id": "eu"
  },
  {
    "label": "Persian",
    "language_alpha2_id": "fa"
  },
  {
    "label": "Fulah",
    "language_alpha2_id": "ff"
  },
  {
    "label": "Finnish",
    "language_alpha2_id": "fi"
  },
  {
    "label": "Fijian",
    "language_alpha2_id": "fj"
  },
  {
    "label": "Faroese",
    "language_alpha2_id": "fo"
  },
  {
    "label": "French",
    "language_alpha2_id": "fr"
  },
  {
    "label": "Western Frisian",
    "language_alpha2_id": "fy"
  },
  {
    "label": "Irish",
    "language_alpha2_id": "ga"
  },
  {
    "label": "Gaelic; Scottish Gaelic",
    "language_alpha2_id": "gd"
  },
  {
    "label": "Galician",
    "language_alpha2_id": "gl"
  },
  {
    "label": "Guarani",
    "language_alpha2_id": "gn"
  },
  {
    "label": "Gujarati",
    "language_alpha2_id": "gu"
  },
  {
    "label": "Manx",
    "language_alpha2_id": "gv"
  },
  {
    "label": "Hausa",
    "language_alpha2_id": "ha"
  },
  {
    "label": "Hebrew",
    "language_alpha2_id": "he"
  },
  {
    "label": "Hindi",
    "language_alpha2_id": "hi"
  },
  {
    "label": "Hiri Motu",
    "language_alpha2_id": "ho"
  },
  {
    "label": "Croatian",
    "language_alpha2_id": "hr"
  },
  {
    "label": "Haitian; Haitian Creole",
    "language_alpha2_id": "ht"
  },
  {
    "label": "Hungarian",
    "language_alpha2_id": "hu"
  },
  {
    "label": "Armenian",
    "language_alpha2_id": "hy"
  },
  {
    "label": "Herero",
    "language_alpha2_id": "hz"
  },
  {
    "label": "Interlingua (International Auxiliary Language Association)",
    "language_alpha2_id": "ia"
  },
  {
    "label": "Indonesian",
    "language_alpha2_id": "id"
  },
  {
    "label": "Interlingue; Occidental",
    "language_alpha2_id": "ie"
  },
  {
    "label": "Igbo",
    "language_alpha2_id": "ig"
  },
  {
    "label": "Sichuan Yi; Nuosu",
    "language_alpha2_id": "ii"
  },
  {
    "label": "Inupiaq",
    "language_alpha2_id": "ik"
  },
  {
    "label": "Ido",
    "language_alpha2_id": "io"
  },
  {
    "label": "Icelandic",
    "language_alpha2_id": "is"
  },
  {
    "label": "Italian",
    "language_alpha2_id": "it"
  },
  {
    "label": "Inuktitut",
    "language_alpha2_id": "iu"
  },
  {
    "label": "Japanese",
    "language_alpha2_id": "ja"
  },
  {
    "label": "Javanese",
    "language_alpha2_id": "jv"
  },
  {
    "label": "Georgian",
    "language_alpha2_id": "ka"
  },
  {
    "label": "Kongo",
    "language_alpha2_id": "kg"
  },
  {
    "label": "Kikuyu; Gikuyu",
    "language_alpha2_id": "ki"
  },
  {
    "label": "Kuanyama; Kwanyama",
    "language_alpha2_id": "kj"
  },
  {
    "label": "Kazakh",
    "language_alpha2_id": "kk"
  },
  {
    "label": "Kalaallisut; Greenlandic",
    "language_alpha2_id": "kl"
  },
  {
    "label": "Central Khmer",
    "language_alpha2_id": "km"
  },
  {
    "label": "Kannada",
    "language_alpha2_id": "kn"
  },
  {
    "label": "Korean",
    "language_alpha2_id": "ko"
  },
  {
    "label": "Kanuri",
    "language_alpha2_id": "kr"
  },
  {
    "label": "Kashmiri",
    "language_alpha2_id": "ks"
  },
  {
    "label": "Kurdish",
    "language_alpha2_id": "ku"
  },
  {
    "label": "Komi",
    "language_alpha2_id": "kv"
  },
  {
    "label": "Cornish",
    "language_alpha2_id": "kw"
  },
  {
    "label": "Kirghiz; Kyrgyz",
    "language_alpha2_id": "ky"
  },
  {
    "label": "Latin",
    "language_alpha2_id": "la"
  },
  {
    "label": "Luxembourgish; Letzeburgesch",
    "language_alpha2_id": "lb"
  },
  {
    "label": "Ganda",
    "language_alpha2_id": "lg"
  },
  {
    "label": "Limburgan; Limburger; Limburgish",
    "language_alpha2_id": "li"
  },
  {
    "label": "Lingala",
    "language_alpha2_id": "ln"
  },
  {
    "label": "Lao",
    "language_alpha2_id": "lo"
  },
  {
    "label": "Lithuanian",
    "language_alpha2_id": "lt"
  },
  {
    "label": "Luba-Katanga",
    "language_alpha2_id": "lu"
  },
  {
    "label": "Latvian",
    "language_alpha2_id": "lv"
  },
  {
    "label": "Malagasy",
    "language_alpha2_id": "mg"
  },
  {
    "label": "Marshallese",
    "language_alpha2_id": "mh"
  },
  {
    "label": "Maori",
    "language_alpha2_id": "mi"
  },
  {
    "label": "Macedonian",
    "language_alpha2_id": "mk"
  },
  {
    "label": "Malayalam",
    "language_alpha2_id": "ml"
  },
  {
    "label": "Mongolian",
    "language_alpha2_id": "mn"
  },
  {
    "label": "Marathi",
    "language_alpha2_id": "mr"
  },
  {
    "label": "Malay",
    "language_alpha2_id": "ms"
  },
  {
    "label": "Maltese",
    "language_alpha2_id": "mt"
  },
  {
    "label": "Burmese",
    "language_alpha2_id": "my"
  },
  {
    "label": "Nauru",
    "language_alpha2_id": "na"
  },
  {
    "label": "Bokm\u00e5l, Norwegian; Norwegian Bokm\u00e5l",
    "language_alpha2_id": "nb"
  },
  {
    "label": "Ndebele, North; North Ndebele",
    "language_alpha2_id": "nd"
  },
  {
    "label": "Nepali",
    "language_alpha2_id": "ne"
  },
  {
    "label": "Ndonga",
    "language_alpha2_id": "ng"
  },
  {
    "label": "Dutch; Flemish",
    "language_alpha2_id": "nl"
  },
  {
    "label": "Norwegian Nynorsk; Nynorsk, Norwegian",
    "language_alpha2_id": "nn"
  },
  {
    "label": "Norwegian",
    "language_alpha2_id": "no"
  },
  {
    "label": "Ndebele, South; South Ndebele",
    "language_alpha2_id": "nr"
  },
  {
    "label": "Navajo; Navaho",
    "language_alpha2_id": "nv"
  },
  {
    "label": "Chichewa; Chewa; Nyanja",
    "language_alpha2_id": "ny"
  },
  {
    "label": "Occitan (post 1500)",
    "language_alpha2_id": "oc"
  },
  {
    "label": "Ojibwa",
    "language_alpha2_id": "oj"
  },
  {
    "label": "Oromo",
    "language_alpha2_id": "om"
  },
  {
    "label": "Oriya",
    "language_alpha2_id": "or"
  },
  {
    "label": "Ossetian; Ossetic",
    "language_alpha2_id": "os"
  },
  {
    "label": "Panjabi; Punjabi",
    "language_alpha2_id": "pa"
  },
  {
    "label": "Pali",
    "language_alpha2_id": "pi"
  },
  {
    "label": "Polish",
    "language_alpha2_id": "pl"
  },
  {
    "label": "Pushto; Pashto",
    "language_alpha2_id": "ps"
  },
  {
    "label": "Portuguese",
    "language_alpha2_id": "pt"
  },
  {
    "label": "Quechua",
    "language_alpha2_id": "qu"
  },
  {
    "label": "Romansh",
    "language_alpha2_id": "rm"
  },
  {
    "label": "Rundi",
    "language_alpha2_id": "rn"
  },
  {
    "label": "Romanian; Moldavian; Moldovan",
    "language_alpha2_id": "ro"
  },
  {
    "label": "Russian",
    "language_alpha2_id": "ru"
  },
  {
    "label": "Kinyarwanda",
    "language_alpha2_id": "rw"
  },
  {
    "label": "Sanskrit",
    "language_alpha2_id": "sa"
  },
  {
    "label": "Sardinian",
    "language_alpha2_id": "sc"
  },
  {
    "label": "Sindhi",
    "language_alpha2_id": "sd"
  },
  {
    "label": "Northern Sami",
    "language_alpha2_id": "se"
  },
  {
    "label": "Sango",
    "language_alpha2_id": "sg"
  },
  {
    "label": "Sinhala; Sinhalese",
    "language_alpha2_id": "si"
  },
  {
    "label": "Slovak",
    "language_alpha2_id": "sk"
  },
  {
    "label": "Slovenian",
    "language_alpha2_id": "sl"
  },
  {
    "label": "Samoan",
    "language_alpha2_id": "sm"
  },
  {
    "label": "Shona",
    "language_alpha2_id": "sn"
  },
  {
    "label": "Somali",
    "language_alpha2_id": "so"
  },
  {
    "label": "Albanian",
    "language_alpha2_id": "sq"
  },
  {
    "label": "Serbian",
    "language_alpha2_id": "sr"
  },
  {
    "label": "Swati",
    "language_alpha2_id": "ss"
  },
  {
    "label": "Sotho, Southern",
    "language_alpha2_id": "st"
  },
  {
    "label": "Sundanese",
    "language_alpha2_id": "su"
  },
  {
    "label": "Swedish",
    "language_alpha2_id": "sv"
  },
  {
    "label": "Swahili",
    "language_alpha2_id": "sw"
  },
  {
    "label": "Tamil",
    "language_alpha2_id": "ta"
  },
  {
    "label": "Telugu",
    "language_alpha2_id": "te"
  },
  {
    "label": "Tajik",
    "language_alpha2_id": "tg"
  },
  {
    "label": "Thai",
    "language_alpha2_id": "th"
  },
  {
    "label": "Tigrinya",
    "language_alpha2_id": "ti"
  },
  {
    "label": "Turkmen",
    "language_alpha2_id": "tk"
  },
  {
    "label": "Tagalog",
    "language_alpha2_id": "tl"
  },
  {
    "label": "Tswana",
    "language_alpha2_id": "tn"
  },
  {
    "label": "Tonga (Tonga Islands)",
    "language_alpha2_id": "to"
  },
  {
    "label": "Turkish",
    "language_alpha2_id": "tr"
  },
  {
    "label": "Tsonga",
    "language_alpha2_id": "ts"
  },
  {
    "label": "Tatar",
    "language_alpha2_id": "tt"
  },
  {
    "label": "Twi",
    "language_alpha2_id": "tw"
  },
  {
    "label": "Tahitian",
    "language_alpha2_id": "ty"
  },
  {
    "label": "Uighur; Uyghur",
    "language_alpha2_id": "ug"
  },
  {
    "label": "Ukrainian",
    "language_alpha2_id": "uk"
  },
  {
    "label": "Urdu",
    "language_alpha2_id": "ur"
  },
  {
    "label": "Uzbek",
    "language_alpha2_id": "uz"
  },
  {
    "label": "Venda",
    "language_alpha2_id": "ve"
  },
  {
    "label": "Vietnamese",
    "language_alpha2_id": "vi"
  },
  {
    "label": "Volap\u00fck",
    "language_alpha2_id": "vo"
  },
  {
    "label": "Walloon",
    "language_alpha2_id": "wa"
  },
  {
    "label": "Wolof",
    "language_alpha2_id": "wo"
  },
  {
    "label": "Xhosa",
    "language_alpha2_id": "xh"
  },
  {
    "label": "Yiddish",
    "language_alpha2_id": "yi"
  },
  {
    "label": "Yoruba",
    "language_alpha2_id": "yo"
  },
  {
    "label": "Zhuang; Chuang",
    "language_alpha2_id": "za"
  },
  {
    "label": "Chinese",
    "language_alpha2_id": "zh"
  },
  {
    "label": "Zulu",
    "language_alpha2_id": "zu"
  }
]
'::json)
  )
INSERT INTO iso.language_alpha2 (language_alpha2_id, label)
SELECT
  final.language_alpha2_id,
  final.label
FROM import
CROSS JOIN LATERAL json_populate_recordset(null::iso.language_alpha2, doc) as final
ON CONFLICT DO NOTHING;

-- see https://www.postgresql.org/docs/current/sql-cluster.html
CLUSTER VERBOSE iso.language_alpha2;
