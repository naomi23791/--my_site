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
