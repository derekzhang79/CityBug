var nowDate = new Date();
var catItems = ['ไฟฟ้า','ประปา','ถนน','ขนส่งมวลชน','ชุมชน','สาธารณสมบัติ','อื่นๆ'];
var users = [
                {
                    "username": "admin",
                    "password": "qwer4321",
                    "email": "admin@citybug.in.th",
                    "created_at": "2012-09-21T09:39:52.921Z",
                    "last_modified": "2012-09-21T09:39:52.921Z"
                },
                {
                    "username": "user",
                    "password": "qwer4321",
                    "email": "user@citybug.in.th",
                    "created_at": "2012-09-21T09:39:52.921Z",
                    "last_modified": "2012-09-21T09:39:52.921Z"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.503Z",
                    "created_at": "2012-09-26T09:58:09.503Z",
                    "email": "anyarat@opendream.co.th",
                    "password": "1234",
                    "username": "anyarat"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.503Z",
                    "created_at": "2012-09-26T09:58:09.503Z",
                    "email": "apirak@opendream.co.th",
                    "password": "1234",
                    "username": "apirak"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.503Z",
                    "created_at": "2012-09-26T09:58:09.503Z",
                    "email": "anusorn@opendream.co.th",
                    "password": "1234",
                    "username": "anusorn"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.503Z",
                    "created_at": "2012-09-26T09:58:09.503Z",
                    "email": "arthit@opendream.co.th",
                    "password": "1234",
                    "username": "arthit"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.504Z",
                    "created_at": "2012-09-26T09:58:09.504Z",
                    "email": "chatchai@opendream.co.th",
                    "password": "1234",
                    "username": "chatchai"                
                },
                {
                    "last_modified": "2012-09-26T09:58:09.504Z",
                    "created_at": "2012-09-26T09:58:09.504Z",
                    "email": "chongsawad@opendream.co.th",
                    "password": "1234",
                    "username": "chongsawad"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.504Z",
                    "created_at": "2012-09-26T09:58:09.504Z",
                    "email": "nattapol@opendream.co.th",
                    "password": "1234",
                    "username": "nattapol"                
                },
                {
                    "last_modified": "2012-09-26T09:58:09.505Z",
                    "created_at": "2012-09-26T09:58:09.505Z",
                    "email": "nat@opendream.co.th",
                    "password": "1234",
                    "username": "nat"                
                },
                {
                    "last_modified": "2012-09-26T09:58:09.505Z",
                    "created_at": "2012-09-26T09:58:09.505Z",
                    "email": "nawaporn@opendream.co.th",
                    "password": "1234",
                    "username": "nawaporn"                
                },
                {
                    "last_modified": "2012-09-26T09:58:09.506Z",
                    "created_at": "2012-09-26T09:58:09.506Z",
                    "email": "nirut@opendream.co.th",
                    "password": "1234",
                    "username": "nirut"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.506Z",
                    "created_at": "2012-09-26T09:58:09.506Z",
                    "email": "nutchaya@opendream.co.th",
                    "password": "1234",
                    "username": "nutchaya"                
                },
                {
                    "last_modified": "2012-09-26T09:58:09.507Z",
                    "created_at": "2012-09-26T09:58:09.507Z",
                    "email": "nut@opendream.co.th",
                    "password": "1234",
                    "username": "nut"                
                },
                {
                    "last_modified": "2012-09-26T09:58:09.507Z",
                    "created_at": "2012-09-26T09:58:09.507Z",
                    "email": "panudate@opendream.co.th",
                    "password": "1234",
                    "username": "panudate"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.508Z",
                    "created_at": "2012-09-26T09:58:09.508Z",
                    "email": "panu@opendream.co.th",
                    "password": "1234",
                    "username": "panu"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.508Z",
                    "created_at": "2012-09-26T09:58:09.508Z",
                    "email": "patcharaporn@opendream.co.th",
                    "password": "1234",
                    "username": "patcharaporn"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.508Z",
                    "created_at": "2012-09-26T09:58:09.508Z",
                    "email": "patipat@opendream.co.th",
                    "password": "1234",
                    "username": "patipat"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.508Z",
                    "created_at": "2012-09-26T09:58:09.508Z",
                    "email": "pirapa@opendream.co.th",
                    "password": "1234",
                    "username": "pirapa"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.509Z",
                    "created_at": "2012-09-26T09:58:09.509Z",
                    "email": "polawat@opendream.co.th",
                    "password": "1234",
                    "username": "polawat"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.509Z",
                    "created_at": "2012-09-26T09:58:09.509Z",
                    "email": "prathan@opendream.co.th",
                    "password": "1234",
                    "username": "prathan"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.510Z",
                    "created_at": "2012-09-26T09:58:09.509Z",
                    "email": "sarocha@opendream.co.th",
                    "password": "1234",
                    "username": "sarocha"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.510Z",
                    "created_at": "2012-09-26T09:58:09.510Z",
                    "email": "siriwat@opendream.co.th",
                    "password": "1234",
                    "username": "siriwat"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.510Z",
                    "created_at": "2012-09-26T09:58:09.510Z",
                    "email": "supatjaree@opendream.co.th",
                    "password": "1234",
                    "username": "supatjaree"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.511Z",
                    "created_at": "2012-09-26T09:58:09.511Z",
                    "email": "tawee@opendream.co.th",
                    "password": "1234",
                    "username": "tawee"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.511Z",
                    "created_at": "2012-09-26T09:58:09.511Z",
                    "email": "teerapong@opendream.co.th",
                    "password": "1234",
                    "username": "teerapong"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.511Z",
                    "created_at": "2012-09-26T09:58:09.511Z",
                    "email": "teerarat@opendream.co.th",
                    "password": "1234",
                    "username": "teerarat"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.512Z",
                    "created_at": "2012-09-26T09:58:09.512Z",
                    "email": "thanyawan@opendream.co.th",
                    "password": "1234",
                    "username": "thanyawan"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.512Z",
                    "created_at": "2012-09-26T09:58:09.512Z",
                    "email": "tarongpong@opendream.co.th",
                    "password": "1234",
                    "username": "tarongpong"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.514Z",
                    "created_at": "2012-09-26T09:58:09.513Z",
                    "email": "thawatchai@opendream.co.th",
                    "password": "1234",
                    "username": "thawatchai"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.516Z",
                    "created_at": "2012-09-26T09:58:09.516Z",
                    "email": "twin@opendream.co.th",
                    "password": "1234",
                    "username": "twin"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.516Z",
                    "created_at": "2012-09-26T09:58:09.516Z",
                    "email": "veerapong@opendream.co.th",
                    "password": "1234",
                    "username": "veerapong"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.517Z",
                    "created_at": "2012-09-26T09:58:09.517Z",
                    "email": "wasan@opendream.co.th",
                    "password": "1234",
                    "username": "wasan"
                },
                {
                    "last_modified": "2012-09-26T09:58:09.517Z",
                    "created_at": "2012-09-26T09:58:09.517Z",
                    "email": "pui@opendream.co.th",
                    "password": "1234",
                    "username": "pui"
                }
            ];
var places = [
    {
        "distance": 0.07444324802004024,
        "type": "suggested",
        "created_at": "2012-09-21T09:39:52.921Z",
        "last_modified": "2012-09-21T09:39:52.921Z",
        "lng": -73.98427,
        "lat": 40.720658,
        "title": "the living theater",
        "id_foursquare": "4ada58f4f964a520a52121e3"
    },
    {
        "distance": 0.1,
        "type": "suggested",
        "last_modified": "2012-09-21T08:41:13.446Z",
        "created_at": "2012-09-21T08:41:13.446Z",
        "lng": -73.98428,
        "lat": 40.7209,
        "id_foursquare": "mockupplaceid",
        "title": "สวนดอกจ้า"
    },
    {
        "created_at": "2012-09-21T09:45:02.239Z",
        "type": "suggested",
        "last_modified": "2012-09-21T09:45:02.239Z",
        "lng": -73.98332129,
        "lat": 40.722262,
        "distance": 101,
        "title": "Idle Hands Bar",
        "id_foursquare": "4bc779d992b376b07cca4f3a"
    },
    {
        "created_at": "2012-09-21T09:45:02.239Z",
        "type": "suggested",
        "last_modified": "2012-09-21T09:45:02.239Z",
        "lng": -73.98334980010986,
        "lat": 40.72233145987863,
        "distance": 127,
        "title": "Croxley's Ale House",
        "id_foursquare": "3fd66200f964a520e2f11ee3"
    },
    {
        "created_at": "2012-09-21T09:45:02.241Z",
        "type": "suggested",
        "last_modified": "2012-09-21T09:45:02.241Z",
        "lng": -73.983208,
        "lat": 40.722342,
        "distance": 134,
        "title": "Billy Hurricane's",
        "id_foursquare": "4c521c3d99ecc9b6a2c05d5a"
    },
    {
        "created_at": "2012-09-21T09:45:02.239Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.239Z",
        "lng": -73.983994,
        "lat": 40.721294,
        "distance": 0,
        "title": "Clinton Street Baking Co.",
        "id_foursquare": "40a55d80f964a52020f31ee3"
    },
    {
        "created_at": "2012-09-21T09:45:02.241Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.241Z",
        "lng": -73.98449223708757,
        "lat": 40.721609485383816,
        "distance": 54,
        "title": "The Bench.",
        "id_foursquare": "4e58363cc65b219786a909fc"
    },
    {
        "created_at": "2012-09-21T09:45:02.246Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.246Z",
        "lng": -73.9846070190824,
        "lat": 40.72111893965933,
        "distance": 55,
        "title": "Style Like U",
        "id_foursquare": "4f60c898e4b0f16f29056891"
    },
    {
        "created_at": "2012-09-21T09:45:02.246Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.246Z",
        "lng": -73.984595540886,
        "lat": 40.72151928153547,
        "distance": 56,
        "title": "A Little Wicked",
        "id_foursquare": "4b32ca69f964a520fe1325e3"
    },
    {
        "created_at": "2012-09-21T09:45:02.245Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.245Z",
        "lng": -73.98475049647948,
        "lat": 40.721000102885576,
        "distance": 71,
        "title": "Subway",
        "id_foursquare": "4e4c7a99bd413c4cc669b125"
    },
    {
        "created_at": "2012-09-21T09:45:02.246Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.246Z",
        "lng": -73.98425693378371,
        "lat": 40.72067826445507,
        "distance": 72,
        "title": "20 Clinton St Barbershop",
        "id_foursquare": "4f0b5378e4b000dd785b971b"
    },
    {
        "created_at": "2012-09-21T09:45:02.240Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.240Z",
        "lng": -73.984641,
        "lat": 40.721719,
        "distance": 72,
        "title": "Dunkin' Donuts",
        "id_foursquare": "4bdc4bfdfed22d7f649a57c9"
    },
    {
        "created_at": "2012-09-21T09:45:02.240Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.240Z",
        "lng": -73.983596,
        "lat": 40.721891,
        "distance": 74,
        "title": "Lost Kittenz Club House",
        "id_foursquare": "4fdd2c08e4b03622b1a339ee"
    },
    {
        "created_at": "2012-09-21T09:45:02.240Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.240Z",
        "lng": -73.98427,
        "lat": 40.720658,
        "distance": 74,
        "title": "The Living Theater",
        "id_foursquare": "4ada58f4f964a520a52121e3"
    },
    {
        "created_at": "2012-09-21T09:45:02.243Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.243Z",
        "lng": -73.984522,
        "lat": 40.721846,
        "distance": 75,
        "title": "Fed Ex",
        "id_foursquare": "4cd07b4b1ac7a1cd0fc51992"
    },
    {
        "created_at": "2012-09-21T09:45:02.239Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.239Z",
        "lng": -73.984246,
        "lat": 40.720623,
        "distance": 77,
        "title": "Cocoa Bar",
        "id_foursquare": "4657db7ef964a5200f471fe3"
    },
    {
        "created_at": "2012-09-21T09:45:02.245Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.245Z",
        "lng": -73.98427,
        "lat": 40.720589,
        "distance": 81,
        "title": "First Choice Barbershop",
        "id_foursquare": "4da097216fd254815487629b"
    },
    {
        "created_at": "2012-09-21T09:45:02.245Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.245Z",
        "lng": -73.984379,
        "lat": 40.720622,
        "distance": 81,
        "title": "The Smokehoss",
        "id_foursquare": "4f8b64bae4b0af04c2585586"
    },
    {
        "created_at": "2012-09-21T09:45:02.246Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.246Z",
        "lng": -73.98469310553351,
        "lat": 40.72075947467961,
        "distance": 83,
        "title": "162 Stanton St",
        "id_foursquare": "4e3551bb483bf3839a2d282e"
    },
    {
        "created_at": "2012-09-21T09:45:02.240Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.240Z",
        "lng": -73.984806,
        "lat": 40.721741,
        "distance": 84,
        "title": "The Local 269",
        "id_foursquare": "49bb6c8af964a520e7531fe3"
    },
    {
        "created_at": "2012-09-21T09:45:02.245Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.245Z",
        "lng": -73.984378,
        "lat": 40.720573,
        "distance": 86,
        "title": "23 Clinton Street",
        "id_foursquare": "4f7396e5e4b03ea6fe1f024c"
    },
    {
        "created_at": "2012-09-21T09:45:02.241Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.241Z",
        "lng": -73.984809,
        "lat": 40.721773,
        "distance": 87,
        "title": "FedEx Office Print & Ship Center",
        "id_foursquare": "4b1818e3f964a520dfcc23e3"
    },
    {
        "created_at": "2012-09-21T09:45:02.242Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.242Z",
        "lng": -73.982941,
        "lat": 40.721349,
        "distance": 89,
        "title": "Mooka and Tinkerbell's Place",
        "id_foursquare": "4eb30da7d3e3bcda5adc8655"
    },
    {
        "created_at": "2012-09-21T09:45:02.241Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.241Z",
        "lng": -73.984926,
        "lat": 40.721676,
        "distance": 89,
        "title": "L'Oubli Gourmet Bar",
        "id_foursquare": "4c6350df58810f479795091e"
    },
    {
        "created_at": "2012-09-21T09:45:02.245Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.245Z",
        "lng": -73.98286232535908,
        "lat": 40.72126218456357,
        "distance": 95,
        "title": "El Maguey y La Tuna",
        "id_foursquare": "459f6987f964a520c0401fe3"
    },
    {
        "created_at": "2012-09-21T09:45:02.241Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.241Z",
        "lng": -73.982831,
        "lat": 40.721221,
        "distance": 98,
        "title": "LES Diggs",
        "id_foursquare": "4c89a76e9ef0224b7d68547b"
    },
    {
        "created_at": "2012-09-21T09:45:02.241Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.241Z",
        "lng": -73.98438319412892,
        "lat": 40.72041790246302,
        "distance": 102,
        "title": "Salt Bar",
        "id_foursquare": "4106ec80f964a5208f0b1fe3"
    },
    {
        "created_at": "2012-09-21T09:45:02.239Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.239Z",
        "lng": -73.98347067431185,
        "lat": 40.722126576323426,
        "distance": 102,
        "title": "Cornerstone Cafe",
        "id_foursquare": "4dea657bfa76cc1b8ae3bb30"
    },
    {
        "created_at": "2012-09-21T09:45:02.246Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.246Z",
        "lng": -73.98383223928617,
        "lat": 40.720338,
        "distance": 107,
        "title": "Moldy Fizz Jazz Club",
        "id_foursquare": "4dbdf176fa8cee727374688f"
    },
    {
        "created_at": "2012-09-21T09:45:02.245Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.245Z",
        "lng": -73.985164,
        "lat": 40.720881,
        "distance": 108,
        "title": "pandapanther",
        "id_foursquare": "4c796c6e3badb1f7c10d4f54"
    },
    {
        "created_at": "2012-09-21T09:45:02.241Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.241Z",
        "lng": -73.98414661,
        "lat": 40.722314,
        "distance": 114,
        "title": "Il Posto Accanto",
        "id_foursquare": "42893400f964a5206c231fe3"
    },
    {
        "created_at": "2012-09-21T09:45:02.246Z",
        "type": "additional",
        "last_modified": "2012-09-21T09:45:02.246Z",
        "lng": -73.9840780198574,
        "lat": 40.72234721402162,
        "distance": 117,
        "title": "Il Bagatto",
        "id_foursquare": "3fd66200f964a52025e51ee3"
    }
]