from django.test import TestCase
from .models import Language
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status

# Create your tests here.

class LanguageModelTest(TestCase):
    def test_language_str(self):
        lang = Language.objects.create(name="English", code="EN")
        self.assertEqual(str(lang), "English")

class LanguageApiTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.language_data = {"name": "Spanish", "code": "ES"}

    def test_create_language(self):
        response = self.client.post(reverse('language-list'), self.language_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['name'], "Spanish")


class AuthApiTest(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_register_and_login(self):
        register_data = {"username": "testuser", "email": "u@example.com", "password": "password123"}
        # Register
        resp = self.client.post(reverse('register'), register_data, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertIn('token', resp.data)

        # Login
        login_data = {"username": "testuser", "password": "password123"}
        resp2 = self.client.post(reverse('login'), login_data, format='json')
        self.assertEqual(resp2.status_code, status.HTTP_200_OK)
        self.assertIn('token', resp2.data)

    def test_daily_challenge_requires_auth(self):
        # Unauthenticated should return 401
        resp = self.client.get(reverse('daily-challenge'))
        self.assertIn(resp.status_code, (status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN))
