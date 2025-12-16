import json
import unittest
from create_post import lambda_handler
from unittest.mock import MagicMock, patch

class TestCreatePost(unittest.TestCase):
    def setUp(self):
        self.mock_dynamodb = patch('boto3.resource').start()
        self.mock_table = MagicMock()
        self.mock_dynamodb.return_value.Table.return_value = self.mock_table

    def tearDown(self):
        patch.stopall()

    def test_valid_input(self):
        event = {
            'body': json.dumps({
                'name': 'Test User',
                'message': 'This is a valid message.'
            })
        }
        response = lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 201)

    def test_missing_name(self):
        event = {
            'body': json.dumps({
                'message': 'Message without name'
            })
        }
        response = lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 400)
        self.assertIn('Missing required field: name', response['body'])

    def test_name_too_long(self):
        event = {
            'body': json.dumps({
                'name': 'A' * 51,
                'message': 'Message with long name'
            })
        }
        response = lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 400)
        self.assertIn('Name must be a string and less than 50 characters', response['body'])

    def test_message_too_long(self):
        event = {
            'body': json.dumps({
                'name': 'Test User',
                'message': 'A' * 1001
            })
        }
        response = lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 400)
        self.assertIn('Message must be a string and less than 1000 characters', response['body'])

if __name__ == '__main__':
    unittest.main()
