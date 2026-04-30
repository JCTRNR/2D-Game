# Collision layers

Use these layers consistently. Do not guess in scripts.

| Layer | Name | Purpose |
|---:|---|---|
| 1 | player | Player body collision |
| 2 | enemy | Enemy body collision |
| 3 | world | Ground, platforms, walls |
| 4 | player_hitbox | Player attack detection |
| 5 | enemy_hitbox | Enemy attack detection |
| 6 | player_hurtbox | Area where player can receive hits |
| 7 | enemy_hurtbox | Area where enemies can receive hits |

## Rules

- Player body collides with world.
- Enemy body collides with world.
- Player hitbox detects enemy hurtbox.
- Enemy hitbox detects player hurtbox.
- Hitboxes should not collide with world.
- Hurtboxes should not block movement.
- Body collision and combat detection stay separate.