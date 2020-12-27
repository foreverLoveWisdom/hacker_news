# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#stories'
  get 'story', to: 'home#story'
end
