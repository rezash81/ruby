RAILS_ENV=production bundle exec rake assets:clobber
#RAILS_ENV=production bundle exec rake assets:precompile
RAILS_RELATIVE_URL_ROOT="/assets" RAILS_ENV=production bundle exec rake assets:precompile
cd public/assets
mv pcal-*.png pcal.png
mv themes-*.gif themes.gif
#cd font-awesome
mv fontawesome-webfont-*.svg fontawesome-webfont.svg
mv fontawesome-webfont-*.ttf fontawesome-webfont.ttf
mv fontawesome-webfont-*.eot fontawesome-webfont.eot
mv fontawesome-webfont-*.woff fontawesome-webfont.woff
#cd ../../..
cd ../..
