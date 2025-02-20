import json
import random
import logging
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Conceptual Database for Magic items
ITEMS = {
    "Shadowfang": {
        "rarity": "Epic",
        "description": "A blade that whispers the secrets of the night.",
        "power": 87
    },
    "Stormbringer": {
        "rarity": "Legendary",
        "description": "A hammer crackling with the energy of a thousand storms.",
        "power": 95
    },
    "Eldertome": {
        "rarity": "Rare",
        "description": "A dusty tome filled with forgotten spells.",
        "power": 72
    },
    "Phantom Cloak": {
        "rarity": "Uncommon",
        "description": "A cloak that flickers between the material and ethereal planes.",
        "power": 58
    },
    "Inferno Dagger": {
        "rarity": "Rare",
        "description": "A dagger that burns with an undying flame.",
        "power": 80
    },
    "Gauntlet of Titans": {
        "rarity": "Legendary",
        "description": "A massive gauntlet that grants superhuman strength.",
        "power": 99
    },
    "Venomfang": {
        "rarity": "Epic",
        "description": "A bow that poisons its targets with deadly precision.",
        "power": 85
    },
    "Void Amulet": {
        "rarity": "Common",
        "description": "A mysterious amulet that absorbs weak spells.",
        "power": 40
    },
    "Echoing Horn": {
        "rarity": "Uncommon",
        "description": "A horn that, when blown, repeats its sound three times.",
        "power": 55
    },
    "Crystal Aegis": {
        "rarity": "Rare",
        "description": "A shield made of enchanted crystal, reflecting magic attacks.",
        "power": 78
    }
}

def lambda_handler(event, context):
    # Log the request
    timestamp = datetime.now().isoformat()
    logger.info(f"Request received at {timestamp}")
    
    try:
        # Get query parameters
        query_parameters = event.get('queryStringParameters', {})
        if not query_parameters or 'name' not in query_parameters:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Please provide an item name using the "name" query parameter.'
                })
            }
        
        item_name = query_parameters['name']
        logger.info(f"Looking up item: {item_name}")
        
        # Handle random item request
        if item_name.lower() == 'random':
            random_item_name = random.choice(list(ITEMS.keys()))
            item_data = ITEMS[random_item_name]
            response_data = {
                'name': random_item_name,
                **item_data
            }
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(response_data)
            }
        
        # Case-insensitive lookup
        item_found = None
        for db_item_name, item_data in ITEMS.items():
            if db_item_name.lower() == item_name.lower():
                item_found = {
                    'name': db_item_name,
                    **item_data
                }
                break
        
        if item_found:
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(item_found)
            }
        else:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Item not found. Try another name.'
                })
            }
            
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error'
            })
        }

